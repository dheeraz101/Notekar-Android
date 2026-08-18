import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';

extension LocalizedString on String {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return this;

    // Normalize string key mapping
    final key = trim().replaceAll('’', "'");
    final normKey = key.toLowerCase();

    // Check language maps for German, Japanese, and Russian
    if (l10n.localeName == 'de') {
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
      'notekar' || 'apptitle' => l10n.appTitle,
      'settings' || 'settingstitle' => l10n.settingsTitle,
      'history' || 'historytitle' => l10n.historyTitle,
      "what's new" ||
      'whats new' ||
      'whatsnewtitle' => switch (l10n.localeName) {
        'es' => 'Novedades',
        'hi' => 'नया क्या है',
        _ => "What's New",
      },
      "what's new in notekar" => switch (l10n.localeName) {
        'es' => 'Novedades en NoteKar',
        'hi' => 'NoteKar में नया क्या है',
        _ => "What's New in NoteKar",
      },
      'changelog' || 'changelogtitle' => l10n.changelogTitle,
      'display' || 'displaycategory' => l10n.displayCategory,
      'accent color' || 'accentcolorcategory' => l10n.accentColorCategory,
      'app icons' || 'appiconscategory' => l10n.appIconsCategory,
      'capture' || 'capturecategory' => l10n.captureCategory,
      'moments' || 'momentscategory' => l10n.momentsCategory,
      'backup & export' ||
      'backup & restore' ||
      'data & backup' ||
      'backup-export' ||
      'backupexportcategory' => l10n.backupExportCategory,
      'privacy & security' ||
      'privacy-security' ||
      'privacysecuritycategory' => l10n.privacySecurityCategory,
      'accessibility' || 'accessibilitycategory' => l10n.accessibilityCategory,
      'reset' || 'resetcategory' => l10n.resetCategory,
      'diagnostics' || 'diagnosticscategory' => l10n.diagnosticsCategory,
      'load older moments' => l10n.loadOlderMoments,
      'no results' || 'no results found' => l10n.noResultsFound,
      'clear search' => l10n.clearSearch,
      'cancel' => l10n.cancel,
      'save' => l10n.save,
      'confirm' => l10n.confirm,
      'delete' => l10n.delete,
      'okay' => switch (l10n.localeName) {
        'es' => 'De acuerdo',
        'hi' => 'ठीक है',
        _ => 'Okay',
      },
      'deleted in moment' => switch (l10n.localeName) {
        'es' => 'Momento IN eliminado',
        'hi' => 'हटाया गया IN क्षण',
        _ => 'Deleted IN moment',
      },
      'deleted out moment' => switch (l10n.localeName) {
        'es' => 'Momento OUT eliminado',
        'hi' => 'हटाया गया OUT क्षण',
        _ => 'Deleted OUT moment',
      },
      'deleted single moment' => switch (l10n.localeName) {
        'es' => 'Momento SINGLE eliminado',
        'hi' => 'हटाया गया SINGLE क्षण',
        _ => 'Deleted SINGLE moment',
      },

      // Sobriety Companion Translations
      'sobriety companion' => switch (l10n.localeName) {
        'es' => 'Compañero de Sobriedad',
        'hi' => 'संयम साथी',
        _ => 'Sobriety Companion',
      },
      'trigger analysis' => switch (l10n.localeName) {
        'es' => 'Análisis de Disparadores',
        'hi' => 'उकसाने वाले कारणों का विश्लेषण',
        _ => 'Trigger Analysis',
      },
      'milestones' => switch (l10n.localeName) {
        'es' => 'Hitos',
        'hi' => 'मील के पत्थर',
        _ => 'Milestones',
      },
      'milestone theme' => switch (l10n.localeName) {
        'es' => 'Tema de Hitos',
        'hi' => 'मील का पत्थर थीम',
        _ => 'Milestone Theme',
      },
      'theme style' => switch (l10n.localeName) {
        'es' => 'Estilo de Tema',
        'hi' => 'थीम शैली',
        _ => 'Theme Style',
      },
      'view all milestones' => switch (l10n.localeName) {
        'es' => 'Ver todos los hitos',
        'hi' => 'सभी मील के पत्थर देखें',
        _ => 'View All Milestones',
      },
      'custom start date' => switch (l10n.localeName) {
        'es' => 'Fecha de Inicio Personalizada',
        'hi' => 'कस्टम प्रारंभ तिथि',
        _ => 'Custom Start Date',
      },
      'set sobriety start date' => switch (l10n.localeName) {
        'es' => 'Establecer Fecha de Inicio',
        'hi' => 'संयम की प्रारंभ तिथि सेट करें',
        _ => 'Set Sobriety Start Date',
      },
      'enable sobriety mode' => switch (l10n.localeName) {
        'es' => 'Activar Modo de Sobriedad',
        'hi' => 'संयम मोड सक्षम करें',
        _ => 'Enable Sobriety Mode',
      },
      'select date and time' => switch (l10n.localeName) {
        'es' => 'Seleccionar Fecha y Hora',
        'hi' => 'दिनांक और समय चुनें',
        _ => 'Select Date and Time',
      },
      'choose milestone theme' => switch (l10n.localeName) {
        'es' => 'Elegir Tema de Hito',
        'hi' => 'मील का पत्थर थीम चुनें',
        _ => 'Choose Milestone Theme',
      },
      'not set: using last log or relapse tag' => switch (l10n.localeName) {
        'es' => 'No establecido: usando último registro o etiqueta de recaída',
        'hi' => 'सेट नहीं है: अंतिम लॉग या रिलैप्स टैग का उपयोग करना',
        _ => 'Not set: using last log or relapse tag',
      },
      'were you already clean before installing? set your actual start date here. this overrides automatic detection from your logs.' =>
        switch (l10n.localeName) {
          'es' =>
            '¿Ya estabas limpio antes de instalar? Establece tu fecha de inicio real aquí. Esto anula la detección automática de tus registros.',
          'hi' =>
            'क्या आप इंस्टॉल करने से पहले ही संयम में थे? अपनी वास्तविक प्रारंभ तिथि यहाँ सेट करें। यह आपके लॉग से स्वचालित पहचान को अधिलेखित कर देता है।',
          _ =>
            'Were you already clean before installing? Set your actual start date here. This overrides automatic detection from your logs.',
        },
      'reset on relapse tag only' => switch (l10n.localeName) {
        'es' => 'Restablecer solo con etiqueta de recaída',
        'hi' => 'केवल रिलैप्स टैग पर रीसेट करें',
        _ => 'Reset on Relapse Tag Only',
      },
      'only moments tagged #relapse reset the streak. turn off to reset on any new log.' =>
        switch (l10n.localeName) {
          'es' =>
            'Solo los momentos etiquetados como #recaida restablecen la racha. Apáguelo para restablecer con cualquier nuevo registro.',
          'hi' =>
            'केवल #relapse टैग किए गए क्षण ही संयम को रीसेट करते हैं। किसी भी नए लॉग पर रीसेट करने के लिए इसे बंद करें।',
          _ =>
            'Only moments tagged #relapse reset the streak. Turn off to reset on any new log.',
        },
      'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.' =>
        switch (l10n.localeName) {
          'es' =>
            'Elige el estilo de narrativa para tus hitos. Cada tema está seleccionado psicológicamente para coincidir con una autoimagen y estilo de motivación diferentes.',
          'hi' =>
            'अपने मील के पत्थर के नामों के लिए कथा शैली चुनें। प्रत्येक थीम को एक अलग आत्म-छवि और प्रेरणा शैली से मेल खाने के लिए मनोवैज्ञानिक रूप से तैयार किया गया है।',
          _ =>
            'Choose the narrative style for your milestone names. Each theme is psychologically curated to match a different self-image and motivation style.',
        },
      'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.' =>
        switch (l10n.localeName) {
          'es' =>
            'Los 21 hitos desde 1 día hasta 10 años, en la neurociencia y psicología del comportamiento. Nombres mostrados en tu tema actual.',
          'hi' =>
            'तंत्रिका विज्ञान, लत सुधार अनुसंधान और व्यवहार मनोविज्ञान में निहित 1 दिन से 10 वर्ष तक के सभी 21 मील के पत्थर। आपकी वर्तमान थीम में नाम दिखाए गए हैं।',
          _ =>
            'All 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. Names shown in your current theme.',
        },
      'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.' =>
        switch (l10n.localeName) {
          'es' =>
            'Seguimiento de racha y diario de recaídas privado. Todos los datos permanecen en tu dispositivo. Los registros existentes nunca se alteran.',
          'hi' =>
            'गोपनीयता-प्रथम संयम ट्रैकिंग और रिलैप्स डायरी। सारा डेटा आपके डिवाइस पर रहता है। मौजूदा लॉग कभी भी नहीं बदले जाते।',
          _ =>
            'Privacy-first streak tracking and relapse diary. All data stays on your device. Existing logs are never altered.',
        },
      'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.' =>
        switch (l10n.localeName) {
          'es' =>
            'Tu pantalla de inicio mostrará una tarjeta de racha en vivo con insignias de hitos. El widget de inicio se adaptará para mostrar botones de reinicio y diario.',
          'hi' =>
            'आपकी होम स्क्रीन मील के पत्थर के बैज के साथ एक लाइव संयम कार्ड दिखाएगी। होम विजेट रीसेट और डायरी बटन दिखाने के लिए अनुकूलित हो जाएगा।',
          _ =>
            'Your home screen will show a live streak card with milestone badges. The home widget will adapt to show reset and diary buttons.',
        },
      'trigger diary' => switch (l10n.localeName) {
        'es' => 'Diario de Disparadores',
        'hi' => 'ट्रिगर डायरी',
        _ => 'Trigger Diary',
      },
      'streak reset logic' => switch (l10n.localeName) {
        'es' => 'Lógica de Reinicio de Racha',
        'hi' => 'संयम रीसेट तर्क',
        _ => 'Streak Reset Logic',
      },
      'streak mode' => switch (l10n.localeName) {
        'es' => 'Modo de Racha',
        'hi' => 'संयम मोड',
        _ => 'Streak Mode',
      },
      'adds a clean streak card to your home screen and adapts home screen widgets.' =>
        switch (l10n.localeName) {
          'es' =>
            'Añade una tarjeta de racha limpia a tu pantalla de inicio y adapta los widgets.',
          'hi' =>
            'आपकी होम स्क्रीन पर एक संयम कार्ड जोड़ता है और होम स्क्रीन विजेट को अनुकूलित करता है।',
          _ =>
            'Adds a clean streak card to your home screen and adapts home screen widgets.',
        },
      'view your relapse pattern insights, top moods, and peak vulnerability windows.' =>
        switch (l10n.localeName) {
          'es' =>
            'Ver información de patrones de recaída, estados de ánimo principales y ventanas de vulnerabilidad máxima.',
          'hi' =>
            'अपने रिलैप्स पैटर्न अंतर्दृष्टि, शीर्ष मूड और चरम संवेदनशीलता विंडो देखें।',
          _ =>
            'View your relapse pattern insights, top moods, and peak vulnerability windows.',
        },
      'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.' =>
        switch (l10n.localeName) {
          'es' =>
            'Al registrar un momento con el Modo de Sobriedad activado, puedes etiquetar el estado de ánimo (Aburrido, Ansioso, Solitario...) y el disparador (Redes Sociales, Tarde en la Noche...). Se guardan como hashtags en la nota para compatibilidad total.',
          'hi' =>
            'संयम मोड चालू होने पर क्षण लॉग करते समय, आप मूड (बोर, चिंतित, अकेला...) और ट्रिगर (सोशल मीडिया, देर रात...) को टैग कर सकते हैं। ये पूर्ण संगतता के लिए नोट में हैशटैग के रूप में सहेजे जाते हैं।',
          _ =>
            'When logging a moment with Sobriety Mode on, you can tag mood (Bored, Anxious, Lonely...) and trigger (Social Media, Late Night...). These are stored as hashtags in the note for full backwards compatibility.',
        },
      'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.' =>
        switch (l10n.localeName) {
          'es' =>
            'Un rastreador de racha y diario de recaídas privado y sin conexión creado para potenciar tu viaje de recuperación.',
          'hi' =>
            'आपकी सुधार यात्रा को सशक्त बनाने के लिए बनाया गया एक गोपनीयता-प्रथम, ऑफ़लाइन संयम ट्रैकिंग और रिलैप्स डायरी।',
          _ =>
            'A privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.',
        },
      'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.' =>
        switch (l10n.localeName) {
          'es' =>
            'Tus datos son 100% privados y permanecen sin conexión en este dispositivo. Activar esto no altera los registros existentes.',
          'hi' =>
            'आपका डेटा 100% निजी है और इस डिवाइस पर ऑफ़लाइन रहता है। इसे सक्षम करने से कोई भी मौजूदा लॉग नहीं बदलता है।',
          _ =>
            'Your data is 100% private and stays offline on this device. Enabling this does not alter any existing logs.',
        },

      'sobriety trigger analysis' => switch (l10n.localeName) {
        'es' => 'Análisis de Disparadores de Sobriedad',
        'hi' => 'संयम ट्रिगर विश्लेषण',
        _ => 'Sobriety Trigger Analysis',
      },
      'total relapses' => switch (l10n.localeName) {
        'es' => 'Total de Recaídas',
        'hi' => 'कुल रिलैप्स',
        _ => 'Total Relapses',
      },
      'top trigger' => switch (l10n.localeName) {
        'es' => 'Disparador Principal',
        'hi' => 'मुख्य ट्रिगर',
        _ => 'Top Trigger',
      },
      'top mood' => switch (l10n.localeName) {
        'es' => 'Estado de Ánimo Principal',
        'hi' => 'मुख्य मूड',
        _ => 'Top Mood',
      },
      'peak risk window' => switch (l10n.localeName) {
        'es' => 'Ventana de Mayor Riesgo',
        'hi' => 'चरम जोखिम समय',
        _ => 'Peak Risk Window',
      },
      'no relapses recorded yet!' => switch (l10n.localeName) {
        'es' => '¡Aún no hay recaídas registradas!',
        'hi' => 'अभी तक कोई रिलैप्स दर्ज नहीं किया गया है!',
        _ => 'No relapses recorded yet!',
      },
      'your clean streak is active and running.' => switch (l10n.localeName) {
        'es' => 'Tu racha limpia está activa y en marcha.',
        'hi' => 'आपकी संयम यात्रा सक्रिय रूप से चल रही है।',
        _ => 'Your clean streak is active and running.',
      },
      'offline analysis of your logged relapse moments. no data leaves your device.' =>
        switch (l10n.localeName) {
          'es' =>
            'Análisis local de tus momentos de recaída registrados. Ningún dato sale de tu dispositivo.',
          'hi' =>
            'आपके दर्ज किए गए रिलैप्स क्षणों का ऑफ़लाइन विश्लेषण। कोई भी डेटा आपके डिवाइस से बाहर नहीं जाता है।',
          _ =>
            'Offline analysis of your logged relapse moments. No data leaves your device.',
        },

      // Common moods
      'bored' => switch (l10n.localeName) {
        'es' => 'Aburrido',
        'hi' => 'ऊबा हुआ',
        _ => 'Bored',
      },
      'anxious' => switch (l10n.localeName) {
        'es' => 'Ansioso',
        'hi' => 'चिंतित',
        _ => 'Anxious',
      },
      'lonely' => switch (l10n.localeName) {
        'es' => 'Solitario',
        'hi' => 'अकेला',
        _ => 'Lonely',
      },
      'tired' => switch (l10n.localeName) {
        'es' => 'Cansado',
        'hi' => 'थका हुआ',
        _ => 'Tired',
      },
      'stressed' => switch (l10n.localeName) {
        'es' => 'Estresado',
        'hi' => 'तनावग्रस्त',
        _ => 'Stressed',
      },
      'angry' => switch (l10n.localeName) {
        'es' => 'Enojado',
        'hi' => 'क्रोधित',
        _ => 'Angry',
      },
      'sad' => switch (l10n.localeName) {
        'es' => 'Triste',
        'hi' => 'उदास',
        _ => 'Sad',
      },
      'happy' => switch (l10n.localeName) {
        'es' => 'Feliz',
        'hi' => 'खुश',
        _ => 'Happy',
      },

      // Common triggers
      'social_media' || 'social media' => switch (l10n.localeName) {
        'es' => 'Redes Sociales',
        'hi' => 'सोशल मीडिया',
        _ => 'Social Media',
      },
      'late_night' || 'late night' => switch (l10n.localeName) {
        'es' => 'Tarde en la Noche',
        'hi' => 'देर रात',
        _ => 'Late Night',
      },
      'stress' => switch (l10n.localeName) {
        'es' => 'Estrés',
        'hi' => 'तनाव',
        _ => 'Stress',
      },
      'boredom' => switch (l10n.localeName) {
        'es' => 'Aburrimiento',
        'hi' => 'ऊब',
        _ => 'Boredom',
      },
      'loneliness' => switch (l10n.localeName) {
        'es' => 'Soledad',
        'hi' => 'अकेलापन',
        _ => 'Loneliness',
      },
      'fatigue' => switch (l10n.localeName) {
        'es' => 'Fatiga',
        'hi' => 'थकान',
        _ => 'Fatigue',
      },
      'friends' => switch (l10n.localeName) {
        'es' => 'Amigos',
        'hi' => 'मित्र',
        _ => 'Friends',
      },
      'location' => switch (l10n.localeName) {
        'es' => 'Ubicación',
        'hi' => 'स्थान',
        _ => 'Location',
      },
      'none' => switch (l10n.localeName) {
        'es' => 'Ninguno',
        'hi' => 'कोई नहीं',
        _ => 'None',
      },

      // Time periods
      'morning' => switch (l10n.localeName) {
        'es' => 'Mañana',
        'hi' => 'सुबह',
        _ => 'Morning',
      },
      'afternoon' => switch (l10n.localeName) {
        'es' => 'Tarde',
        'hi' => 'दोपहर',
        _ => 'Afternoon',
      },
      'evening' => switch (l10n.localeName) {
        'es' => 'Tarde/Noche',
        'hi' => 'शाम',
        _ => 'Evening',
      },
      'night' => switch (l10n.localeName) {
        'es' => 'Noche',
        'hi' => 'रात',
        _ => 'Night',
      },

      'from' => switch (l10n.localeName) {
        'es' => 'Desde',
        'hi' => 'से',
        _ => 'From',
      },
      'at' => switch (l10n.localeName) {
        'es' => 'a las',
        'hi' => 'बजे',
        _ => 'at',
      },

      // Theme names
      'science' => switch (l10n.localeName) {
        'es' => 'Ciencia',
        'hi' => 'विज्ञान',
        _ => 'Science',
      },
      'warrior' => switch (l10n.localeName) {
        'es' => 'Guerrero',
        'hi' => 'योद्धा',
        _ => 'Warrior',
      },
      'navy' => switch (l10n.localeName) {
        'es' => 'Armada',
        'hi' => 'नौसेना',
        _ => 'Navy',
      },
      'clan' => switch (l10n.localeName) {
        'es' => 'Clan',
        'hi' => 'कबीला',
        _ => 'Clan',
      },
      'ancient' => switch (l10n.localeName) {
        'es' => 'Antiguo',
        'hi' => 'प्राचीन',
        _ => 'Ancient',
      },
      'samurai' => switch (l10n.localeName) {
        'es' => 'Samurái',
        'hi' => 'समुराई',
        _ => 'Samurai',
      },
      'space' => switch (l10n.localeName) {
        'es' => 'Espacio',
        'hi' => 'अंतरिक्ष',
        _ => 'Space',
      },
      'kingdom' => switch (l10n.localeName) {
        'es' => 'Reino',
        'hi' => 'साम्राज्य',
        _ => 'Kingdom',
      },
      'monk' => switch (l10n.localeName) {
        'es' => 'Monje',
        'hi' => 'साधु',
        _ => 'Monk',
      },
      'phoenix' => switch (l10n.localeName) {
        'es' => 'Fénix',
        'hi' => 'फ़ीनिक्स',
        _ => 'Phoenix',
      },
      'animal kingdom' => switch (l10n.localeName) {
        'es' => 'Reino Animal',
        'hi' => 'पशु साम्राज्य',
        _ => 'Animal Kingdom',
      },
      'pokemon' => switch (l10n.localeName) {
        'es' => 'Pokémon',
        'hi' => 'पोकेमॉन',
        _ => 'Pokemon',
      },
      'jujutsu kaisen' => switch (l10n.localeName) {
        'es' => 'Jujutsu Kaisen',
        'hi' => 'जुजुत्सु कैसेन',
        _ => 'Jujutsu Kaisen',
      },
      'one piece' => switch (l10n.localeName) {
        'es' => 'One Piece',
        'hi' => 'वन पीस',
        _ => 'One Piece',
      },
      'naruto' => switch (l10n.localeName) {
        'es' => 'Naruto',
        'hi' => 'नारुतो',
        _ => 'Naruto',
      },
      'ben 10' => switch (l10n.localeName) {
        'es' => 'Ben 10',
        'hi' => 'बेन 10',
        _ => 'Ben 10',
      },
      'attack on titan' => switch (l10n.localeName) {
        'es' => 'Ataque a los Titanes',
        'hi' => 'अटैक ऑन टाइटन',
        _ => 'Attack on Titan',
      },
      'bleach' => switch (l10n.localeName) {
        'es' => 'Bleach',
        'hi' => 'ब्लीच',
        _ => 'Bleach',
      },
      'my hero academia' => switch (l10n.localeName) {
        'es' => 'My Hero Academia',
        'hi' => 'माय हीरो एकेडेमिया',
        _ => 'My Hero Academia',
      },
      'vinland saga' => switch (l10n.localeName) {
        'es' => 'Vinland Saga',
        'hi' => 'विनलैंड सागा',
        _ => 'Vinland Saga',
      },
      'demon slayer' => switch (l10n.localeName) {
        'es' => 'Guardianes de la Noche (Demon Slayer)',
        'hi' => 'डिमोन स्लेयर',
        _ => 'Demon Slayer',
      },
      'fullmetal alchemist' => switch (l10n.localeName) {
        'es' => 'Fullmetal Alchemist',
        'hi' => 'फुलमेटल अल्केमिस्ट',
        _ => 'Fullmetal Alchemist',
      },
      'dragon ball' => switch (l10n.localeName) {
        'es' => 'Dragon Ball',
        'hi' => 'ड्रैगन बॉल',
        _ => 'Dragon Ball',
      },
      'code geass' => switch (l10n.localeName) {
        'es' => 'Code Geass',
        'hi' => 'कोड गियास',
        _ => 'Code Geass',
      },
      'death note' => switch (l10n.localeName) {
        'es' => 'Death Note',
        'hi' => 'डेथ नोट',
        _ => 'Death Note',
      },
      'gintama' => switch (l10n.localeName) {
        'es' => 'Gintama',
        'hi' => 'गिंटामा',
        _ => 'Gintama',
      },
      'hunter x hunter' => switch (l10n.localeName) {
        'es' => 'Hunter x Hunter',
        'hi' => 'हंटर एक्स हंटर',
        _ => 'Hunter x Hunter',
      },
      'solo leveling' => switch (l10n.localeName) {
        'es' => 'Solo Leveling',
        'hi' => 'सोलो लेवलिंग',
        _ => 'Solo Leveling',
      },
      'rpg / minecraft' => switch (l10n.localeName) {
        'es' => 'RPG / Minecraft',
        'hi' => 'आरपीजी / माइनक्राफ्ट',
        _ => 'RPG / Minecraft',
      },
      'tech career' => switch (l10n.localeName) {
        'es' => 'Carrera Tecnológica',
        'hi' => 'टेक करियर',
        _ => 'Tech Career',
      },
      'chess mastery' => switch (l10n.localeName) {
        'es' => 'Maestría en Ajedrez',
        'hi' => 'शतरंज महारत',
        _ => 'Chess Mastery',
      },
      'star wars' => switch (l10n.localeName) {
        'es' => 'Star Wars',
        'hi' => 'स्टार वॉर्स',
        _ => 'Star Wars',
      },
      'harry potter' => switch (l10n.localeName) {
        'es' => 'Harry Potter',
        'hi' => 'हैरी पॉटर',
        _ => 'Harry Potter',
      },
      'marvel universe' => switch (l10n.localeName) {
        'es' => 'Universo Marvel',
        'hi' => 'मार्वल यूनिवर्स',
        _ => 'Marvel Universe',
      },

      // Theme Descriptions
      'clinical neuroscience terms. cold, precise, honest.' => switch (l10n
          .localeName) {
        'es' => 'Términos clínicos de neurociencia. Fríos, precisos, honestos.',
        'hi' => 'नैदानिक तंत्रिका विज्ञान शब्द। स्पष्ट, सटीक, ईमानदार।',
        _ => 'Clinical neuroscience terms. Cold, precise, honest.',
      },
      'army elite. every clean day is a battle fought and won.' =>
        switch (l10n.localeName) {
          'es' => 'Élite militar. Cada día limpio es una batalla ganada.',
          'hi' => 'सेना के जवान। हर एक संयमित दिन जीती हुई जंग है।',
          _ => 'Army elite. Every clean day is a battle fought and won.',
        },
      'seafaring odyssey. chart new waters and never look back.' =>
        switch (l10n.localeName) {
          'es' => 'Odisea marítima. Explora nuevas aguas y nunca mires atrás.',
          'hi' =>
            'समुद्री यात्रा। नए रास्तों पर चलें और कभी पीछे मुड़कर न देखें।',
          _ => 'Seafaring odyssey. Chart new waters and never look back.',
        },
      'celtic highland clan. earn your place, carry the banner.' => switch (l10n
          .localeName) {
        'es' =>
          'Clan celta de las tierras altas. Gana tu lugar, lleva el estandarte.',
        'hi' => 'पहाड़ी कबीला। अपनी जगह कमाएं, ध्वज को आगे बढ़ाएं।',
        _ => 'Celtic highland clan. Earn your place, carry the banner.',
      },
      'greek and roman glory. rise from mortal to olympian.' => switch (l10n
          .localeName) {
        'es' => 'Gloria griega y romana. Eleva tu estado de mortal a olímpico.',
        'hi' => 'यूनानी और रोमन महिमा। साधारण मनुष्य से ओलंपियन बनें।',
        _ => 'Greek and Roman glory. Rise from mortal to Olympian.',
      },
      'bushido code. master of the self.' => switch (l10n.localeName) {
        'es' => 'Código Bushido. Dueño de uno mismo.',
        'hi' => 'बुशीडो कोड। स्वयं पर नियंत्रण।',
        _ => 'Bushido code. Master of the self.',
      },
      'cosmic exploration. every clean day is light-years gained.' =>
        switch (l10n.localeName) {
          'es' => 'Exploración cósmica. Cada día limpio son años luz ganados.',
          'hi' => 'अंतरिक्ष अन्वेषण। हर एक संयमित दिन प्रकाश वर्ष के समान है।',
          _ => 'Cosmic exploration. Every clean day is light-years gained.',
        },
      'medieval royalty. rise from serf to sovereign.' =>
        switch (l10n.localeName) {
          'es' => 'Realeza medieval. Asciende de siervo a soberano.',
          'hi' => 'मध्यकालीन राजघराना। दास से शासक बनें।',
          _ => 'Medieval royalty. Rise from serf to sovereign.',
        },
      'monastic journey. silence, stillness, and vows.' =>
        switch (l10n.localeName) {
          'es' => 'Viaje monástico. Silencio, quietud y votos.',
          'hi' => 'मठवासी यात्रा। मौन, स्थिरता और प्रतिज्ञाएं।',
          _ => 'Monastic journey. Silence, stillness, and vows.',
        },
      'rebirth through fire. the old is ash; you are the flame.' => switch (l10n
          .localeName) {
        'es' =>
          'Renacimiento a través del fuego. El pasado es ceniza; tú eres la llama.',
        'hi' => 'अग्नि से पुनर्जन्म। पुराना राख है; आप ज्वाला हैं।',
        _ => 'Rebirth through fire. The old is ash; you are the flame.',
      },
      'survival of the fittest. tardigrade to mythical dragon.' => switch (l10n
          .localeName) {
        'es' => 'Supervivencia del más apto. Del tardígrado al dragón mítico.',
        'hi' => 'योग्यतम की उत्तरजीविता। टार्डिग्रेड से पौराणिक ड्रैगन तक।',
        _ => 'Survival of the fittest. Tardigrade to mythical Dragon.',
      },
      'magikarp to the creator god arceus.' => switch (l10n.localeName) {
        'es' => 'De Magikarp al dios creador Arceus.',
        'hi' => 'मैजिकारप से निर्माता भगवान आर्सियस तक।',
        _ => 'Magikarp to the creator god Arceus.',
      },
      'cursed spirit to satoru gojo.' => switch (l10n.localeName) {
        'es' => 'De espíritu maldito a Satoru Gojo.',
        'hi' => 'शापित आत्मा से सटोरू गोजो तक।',
        _ => 'Cursed spirit to Satoru Gojo.',
      },
      'east blue coby to the pirate king gol d. roger.' =>
        switch (l10n.localeName) {
          'es' => 'De Coby del East Blue al Rey de los Piratas Gol D. Roger.',
          'hi' => 'ईस्ट ब्लू कोबी से समुद्री डाकू राजा गोल डी. रोजर तक।',
          _ => 'East Blue Coby to the Pirate King Gol D. Roger.',
        },
      'konohamaru to the sage of six paths.' => switch (l10n.localeName) {
        'es' => 'De Konohamaru al Sabio de los Seis Caminos.',
        'hi' => 'कोनोहामारू से छह पथों के ऋषि तक।',
        _ => 'Konohamaru to the Sage of Six Paths.',
      },
      'grey matter to alien x.' => switch (l10n.localeName) {
        'es' => 'De Materia Gris a Alien X.',
        'hi' => 'ग्रे मैटर से एलियन एक्स तक।',
        _ => 'Grey Matter to Alien X.',
      },
      'pure titan to the founder ymir fritz.' => switch (l10n.localeName) {
        'es' => 'De Titán puro a la Fundadora Ymir Fritz.',
        'hi' => 'शुद्ध टाइटन से संस्थापक यमिर फ्रिट्ज तक।',
        _ => 'Pure Titan to the Founder Ymir Fritz.',
      },
      'teddy bear kon to yhwach the almighty.' => switch (l10n.localeName) {
        'es' => 'Del peluche Kon a Yhwach el Todopoderoso.',
        'hi' => 'टेडी बियर कॉन से सर्वशक्तिमान इहवाच तक।',
        _ => 'Teddy bear Kon to Yhwach the Almighty.',
      },
      'mineta to all might prime.' => switch (l10n.localeName) {
        'es' => 'De Mineta a All Might Prime.',
        'hi' => 'मिनेटा से ऑल माइट प्राइम तक।',
        _ => 'Mineta to All Might Prime.',
      },
      'priest willibald to thors the troll of jom.' =>
        switch (l10n.localeName) {
          'es' => 'Del sacerdote Willibald a Thors el Trol de Jom.',
          'hi' => 'पुजारी विलीबाल्ड से थोरस द ट्रोल ऑफ जोम तक।',
          _ => 'Priest Willibald to Thors the Troll of Jom.',
        },
      'murata to yoriichi tsugikuni.' => switch (l10n.localeName) {
        'es' => 'De Murata a Yoriichi Tsugikuni.',
        'hi' => 'मुराता से योरीइची सुगिकुनी तक।',
        _ => 'Murata to Yoriichi Tsugikuni.',
      },
      'yoki to the ultimate truth.' => switch (l10n.localeName) {
        'es' => 'De Yoki a la Verdad última.',
        'hi' => 'योकी से परम सत्य तक।',
        _ => 'Yoki to the ultimate Truth.',
      },
      'yamcha to the omni-king zeno.' => switch (l10n.localeName) {
        'es' => 'De Yamcha al Rey de Todo Zeno.',
        'hi' => 'यामचा से ओम्नी-किंग ज़ेनो तक।',
        _ => 'Yamcha to the Omni-King Zeno.',
      },
      'shirley to emperor lelouch vi britannia.' => switch (l10n.localeName) {
        'es' => 'De Shirley al Emperador Lelouch vi Britannia.',
        'hi' => 'शर्ली से सम्राट लेलौच वी ब्रिटानिया तक।',
        _ => 'Shirley to Emperor Lelouch vi Britannia.',
      },
      'matsuda to the shinigami king.' => switch (l10n.localeName) {
        'es' => 'De Matsuda al Rey Shinigami.',
        'hi' => 'मात्सुदा से शिनिगामी किंग तक।',
        _ => 'Matsuda to the Shinigami King.',
      },
      'shinpachi to utsuro.' => switch (l10n.localeName) {
        'es' => 'De Shinpachi a Utsuro.',
        'hi' => 'शिनपाची से उत्सुरो तक।',
        _ => 'Shinpachi to Utsuro.',
      },
      'tonpa to adult gon.' => switch (l10n.localeName) {
        'es' => 'De Tonpa a Gon adulto.',
        'hi' => 'टोंपा से वयस्क गॉन तक।',
        _ => 'Tonpa to Adult Gon.',
      },
      'e-rank sung jinwoo to shadow monarch.' => switch (l10n.localeName) {
        'es' => 'De Sung Jinwoo de rango E al Monarca de las Sombras.',
        'hi' => 'ई-रैंक सुंग जिनवू से शैडो मोनार्क तक।',
        _ => 'E-Rank Sung Jinwoo to Shadow Monarch.',
      },
      'wooden shovel to creative mode god.' => switch (l10n.localeName) {
        'es' => 'De pala de madera a dios del modo creativo.',
        'hi' => 'लकड़ी के बेलचे से क्रिएटिव मोड गॉड तक।',
        _ => 'Wooden Shovel to Creative Mode God.',
      },
      'html editor to turing award winner.' => switch (l10n.localeName) {
        'es' => 'De editor HTML a ganador del Premio Turing.',
        'hi' => 'HTML संपादक से ट्यूरिंग पुरस्कार विजेता तक।',
        _ => 'HTML editor to Turing Award Winner.',
      },
      'scholar\'s mate victim to magnus carlsen.' => switch (l10n.localeName) {
        'es' => 'De víctima del mate del pastor a Magnus Carlsen.',
        'hi' => 'स्कॉलर्स मेट पीड़ित से मैग्नस कार्लसन तक।',
        _ => 'Scholar\'s Mate victim to Magnus Carlsen.',
      },
      'moisture farmer to the chosen one.' => switch (l10n.localeName) {
        'es' => 'De granjero de humedad al Elegido.',
        'hi' => 'नमी किसान से चुने गए व्यक्ति (द चूज़न वन) तक।',
        _ => 'Moisture farmer to the Chosen One.',
      },
      'muggle to merlin.' => switch (l10n.localeName) {
        'es' => 'De Muggle a Merlín.',
        'hi' => 'मगल से मर्लिन तक।',
        _ => 'Muggle to Merlin.',
      },
      'civilian to the one above all.' => switch (l10n.localeName) {
        'es' => 'De civil a El que está por encima de todo.',
        'hi' => 'नागरिक से द वन एबोव ऑल (परमेश्वर) तक।',
        _ => 'Civilian to The One Above All.',
      },

      // Onboarding & Welcome Sheet Translations
      'welcome' => switch (l10n.localeName) {
        'es' => 'Bienvenido',
        'hi' => 'स्वागत',
        _ => 'Welcome',
      },
      'welcome to notekar' => switch (l10n.localeName) {
        'es' => 'Bienvenido a NoteKar',
        'hi' => 'NoteKar में आपका स्वागत है',
        _ => 'Welcome to NoteKar',
      },
      'a quiet, offline-first way to mark moments the second they happen.' =>
        switch (l10n.localeName) {
          'es' =>
            'Una forma silenciosa y local de registrar momentos al instante.',
          'hi' =>
            'क्षणों को तुरंत रिकॉर्ड करने का एक शांत, ऑफ़लाइन-पहला तरीका।',
          _ =>
            'A quiet, offline-first way to mark moments the second they happen.',
        },
      'app theme' => switch (l10n.localeName) {
        'es' => 'Tema de la aplicación',
        'hi' => 'ऐप थीम',
        _ => 'App Theme',
      },
      'theme mode' => switch (l10n.localeName) {
        'es' => 'Modo de tema',
        'hi' => 'थीम मोड',
        _ => 'Theme Mode',
      },
      'get started' => switch (l10n.localeName) {
        'es' => 'Comenzar',
        'hi' => 'शुरू करें',
        _ => 'Get Started',
      },
      'start logging' => switch (l10n.localeName) {
        'es' => 'Comenzar',
        'hi' => 'लॉगिंग शुरू करें',
        _ => 'Start Logging',
      },

      // Guides Page Titles
      'save a moment' => switch (l10n.localeName) {
        'es' => 'Guardar un momento',
        'hi' => 'एक पल सहेजें',
        _ => 'Save a Moment',
      },
      'two-way mode' => switch (l10n.localeName) {
        'es' => 'Modo de dos vías',
        'hi' => 'टू-वे मोड',
        _ => 'Two-Way Mode',
      },
      'single mode' => switch (l10n.localeName) {
        'es' => 'Modo único',
        'hi' => 'सिंगल मोड',
        _ => 'Single Mode',
      },
      'add a note' => switch (l10n.localeName) {
        'es' => 'Añadir una nota',
        'hi' => 'एक नोट जोड़ें',
        _ => 'Add a Note',
      },
      'review history' => switch (l10n.localeName) {
        'es' => 'Revisar historial',
        'hi' => 'इतिहास की समीक्षा करें',
        _ => 'Review History',
      },
      'search notes' => switch (l10n.localeName) {
        'es' => 'Buscar notas',
        'hi' => 'नोट्स खोजें',
        _ => 'Search Notes',
      },
      'time between moments' => switch (l10n.localeName) {
        'es' => 'Tiempo entre momentos',
        'hi' => 'क्षणों के बीच का समय',
        _ => 'Time Between Moments',
      },
      'manage moment notes' => switch (l10n.localeName) {
        'es' => 'Gestionar notas de momentos',
        'hi' => 'क्षण नोट्स प्रबंधित करें',
        _ => 'Manage Moment Notes',
      },
      'app lock timing' => switch (l10n.localeName) {
        'es' => 'Tiempo de bloqueo de app',
        'hi' => 'ऐप लॉक समय',
        _ => 'App Lock Timing',
      },
      'minimal moment options' => switch (l10n.localeName) {
        'es' => 'Opciones mínimas de momentos',
        'hi' => 'न्यूनतम क्षण विकल्प',
        _ => 'Minimal Moment Options',
      },
      'adaptive engine' => switch (l10n.localeName) {
        'es' => 'Motor adaptativo',
        'hi' => 'अनुकूलन योग्य इंजन',
        _ => 'Adaptive Engine',
      },
      'restore deleted moments' => switch (l10n.localeName) {
        'es' => 'Restaurar momentos eliminados',
        'hi' => 'हटाए गए मोमेंट्स पुनर्स्थापित करें',
        _ => 'Restore Deleted Moments',
      },
      'back up data' => switch (l10n.localeName) {
        'es' => 'Copia de seguridad de datos',
        'hi' => 'डेटा का बैकअप लें',
        _ => 'Back Up Data',
      },

      // Help Page Questions
      'can i restore deleted moments?' => switch (l10n.localeName) {
        'es' => '¿Puedo restaurar momentos eliminados?',
        'hi' => 'क्या मैं हटाए गए क्षणों को पुनर्स्थापित कर सकता हूँ?',
        _ => 'Can I restore deleted moments?',
      },
      'update check failed' => switch (l10n.localeName) {
        'es' => 'Fallo al comprobar actualizaciones',
        'hi' => 'अपडेट जांच विफल रही',
        _ => 'Update check failed',
      },
      'app notices are not appearing' => switch (l10n.localeName) {
        'es' => 'Los avisos de la app no aparecen',
        'hi' => 'ऐप सूचनाएं नहीं आ रही हैं',
        _ => 'App Notices are not appearing',
      },
      'notekar is offline' => switch (l10n.localeName) {
        'es' => 'NoteKar está sin conexión',
        'hi' => 'NoteKar ऑफ़लाइन है',
        _ => 'NoteKar is offline',
      },
      'backup import found no new moments' => switch (l10n.localeName) {
        'es' =>
          'La importación de copia de seguridad no encontró nuevos momentos',
        'hi' => 'बैकअप आयात में कोई नया क्षण नहीं मिला',
        _ => 'Backup import found no new moments',
      },
      'backup import failed' => switch (l10n.localeName) {
        'es' => 'Fallo al importar copia de seguridad',
        'hi' => 'बैकअप आयात विफल रहा',
        _ => 'Backup import failed',
      },
      'live icon motion will not turn on' => switch (l10n.localeName) {
        'es' => 'El movimiento de icono en vivo no se activa',
        'hi' => 'लाइव आइकन मोशन चालू नहीं होगा',
        _ => 'Live Icon Motion will not turn on',
      },
      'live icon motion looks slow or delayed' => switch (l10n.localeName) {
        'es' => 'El movimiento de icono en vivo parece lento o retrasado',
        'hi' => 'लाइव आइकन मोशन धीमा या विलंबित दिखता है',
        _ => 'Live Icon Motion looks slow or delayed',
      },
      'app lock will not turn on' => switch (l10n.localeName) {
        'es' => 'El bloqueo de app no se activa',
        'hi' => 'ऐप लॉक चालू नहीं होगा',
        _ => 'App Lock will not turn on',
      },
      'app lock appears after the notification panel' => switch (l10n
          .localeName) {
        'es' => 'El bloqueo de app aparece después del panel de notificaciones',
        'hi' => 'ऐप लॉक नोटिफिकेशन पैनल के बाद दिखाई देता है',
        _ => 'App Lock appears after the notification panel',
      },
      'notekar stores moments privately on this device. backups are files you control.' =>
        switch (l10n.localeName) {
          'es' =>
            'NoteKar guarda momentos de forma privada en este dispositivo. Las copias de seguridad son archivos que tú controlas.',
          'hi' =>
            'NoteKar इस डिवाइस पर क्षणों को निजी रूप से संग्रहीत करता है। बैकअप वे फाइलें हैं जिन्हें आप नियंत्रित करते हैं।',
          _ =>
            'NoteKar stores moments privately on this device. Backups are files you control.',
        },
      'select your preferred language for the application.' =>
        switch (l10n.localeName) {
          'es' => 'Selecciona tu idioma preferido para la aplicación.',
          'hi' => 'एप्लिकेशन के लिए अपनी पसंदीदा भाषा चुनें।',
          _ => 'Select your preferred language for the application.',
        },
      'the current features on this page are under beta stage.' =>
        switch (l10n.localeName) {
          'es' => 'Las funciones actuales de esta página están en fase Beta.',
          'hi' => 'इस पृष्ठ की वर्तमान विशेषताएं बीटा चरण में हैं।',
          _ => 'The current features on this page are under Beta stage.',
        },
      'reminders' => switch (l10n.localeName) {
        'es' => 'Recordatorios',
        'hi' => 'अनुस्मारक',
        _ => 'Reminders',
      },
      'logging reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio de registro',
        'hi' => 'लॉगिंग अनुस्मारक',
        _ => 'Logging Reminder',
      },
      'time to log a moment!' => switch (l10n.localeName) {
        'es' => '¡Hora de registrar un momento!',
        'hi' => 'क्षण लॉग करने का समय!',
        _ => 'Time to log a moment!',
      },
      'daily reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio diario',
        'hi' => 'दैनिक अनुस्मारक',
        _ => 'Daily Reminder',
      },
      'inactivity reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio de inactividad',
        'hi' => 'निष्क्रियता अनुस्मारक',
        _ => 'Inactivity Reminder',
      },
      'weekly reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio semanal',
        'hi' => 'साप्ताहिक अनुस्मारक',
        _ => 'Weekly Reminder',
      },
      'monthly reminder' => switch (l10n.localeName) {
        'es' => 'Recordatorio mensual',
        'hi' => 'मासिक अनुस्मारक',
        _ => 'Monthly Reminder',
      },
      'remind if inactive for' => switch (l10n.localeName) {
        'es' => 'Recordar si está inactivo por',
        'hi' => 'निष्क्रिय होने पर याद दिलाएं',
        _ => 'Remind if inactive for',
      },
      'days of week' => switch (l10n.localeName) {
        'es' => 'Días de la semana',
        'hi' => 'सप्ताह के दिन',
        _ => 'Days of week',
      },
      'day of month' => switch (l10n.localeName) {
        'es' => 'Día del mes',
        'hi' => 'महीने का दिन',
        _ => 'Day of month',
      },
      'trash bin' => switch (l10n.localeName) {
        'es' => 'Papelera',
        'hi' => 'कचरा पात्र',
        _ => 'Trash Bin',
      },
      'current message' => switch (l10n.localeName) {
        'es' => 'Mensaje actual',
        'hi' => 'वर्तमान संदेश',
        _ => 'Current Message',
      },
      'recent messages' => switch (l10n.localeName) {
        'es' => 'Mensajes recientes',
        'hi' => 'हाल के संदेश',
        _ => 'Recent Messages',
      },
      'edit message' => switch (l10n.localeName) {
        'es' => 'Editar mensaje',
        'hi' => 'संदेश संपादित करें',
        _ => 'Edit Message',
      },
      'daily reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio diario',
        'hi' => 'दैनिक अनुस्मारक संदेश',
        _ => 'Daily Reminder Message',
      },
      'weekly reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio semanal',
        'hi' => 'साप्ताहिक अनुस्मारक संदेश',
        _ => 'Weekly Reminder Message',
      },
      'monthly reminder message' => switch (l10n.localeName) {
        'es' => 'Mensaje de recordatorio mensual',
        'hi' => 'मासिक अनुस्मारक संदेश',
        _ => 'Monthly Reminder Message',
      },
      'restore all moments?' => switch (l10n.localeName) {
        'es' => '¿Restaurar todos los momentos?',
        'hi' => 'सभी क्षण पुनर्स्थापित करें?',
        _ => 'Restore All Moments?',
      },
      'this will return all items currently in the trash to your history.' =>
        switch (l10n.localeName) {
          'es' =>
            'Esto devolverá todos los elementos actualmente en la papelera a su historial.',
          'hi' =>
            'यह वर्तमान में कचरा पात्र में मौजूद सभी वस्तुओं को आपके इतिहास में वापस कर देगा।',
          _ =>
            'This will return all items currently in the trash to your history.',
        },
      'restore all' => switch (l10n.localeName) {
        'es' => 'Restaurar todo',
        'hi' => 'सभी को पुनर्स्थापित करें',
        _ => 'Restore All',
      },
      'empty trash?' => switch (l10n.localeName) {
        'es' => '¿Vaciar papelera?',
        'hi' => 'कचरा पात्र खाली करें?',
        _ => 'Empty Trash?',
      },
      'this will permanently delete all moments in the trash. this action cannot be undone.' =>
        switch (l10n.localeName) {
          'es' =>
            'Esto eliminará permanentemente todos los momentos de la papelera. Esta acción no se puede deshacer.',
          'hi' =>
            'यह कचरा पात्र के सभी क्षणों को स्थायी रूप से हटा देगा। यह क्रिया पूर्ववत नहीं की जा सकती।',
          _ =>
            'This will permanently delete all moments in the trash. This action cannot be undone.',
        },
      'delete permanently?' => switch (l10n.localeName) {
        'es' => '¿Eliminar permanentemente?',
        'hi' => 'स्थायी रूप से हटाएं?',
        _ => 'Delete Permanently?',
      },
      'this moment will be erased forever.' => switch (l10n.localeName) {
        'es' => 'Este momento se borrará para siempre.',
        'hi' => 'यह क्षण हमेशा के लिए मिटा दिया जाएगा।',
        _ => 'This moment will be erased forever.',
      },
      'item' => switch (l10n.localeName) {
        'es' => 'elemento',
        'hi' => 'वस्तु',
        _ => 'item',
      },
      'items' => switch (l10n.localeName) {
        'es' => 'elementos',
        'hi' => 'वस्तुओं',
        _ => 'items',
      },
      'no note' => switch (l10n.localeName) {
        'es' => 'Sin nota',
        'hi' => 'कोई नोट नहीं',
        _ => 'No note',
      },
      'recently deleted' => switch (l10n.localeName) {
        'es' => 'ELIMINADO RECIENTEMENTE',
        'hi' => 'हाल ही में हटाया गया',
        _ => 'RECENTLY DELETED',
      },
      'restore or permanently remove deleted moments' => switch (l10n
          .localeName) {
        'es' => 'Restaurar o eliminar permanentemente momentos eliminados',
        'hi' => 'हटाए गए क्षणों को पुनर्स्थापित करें या स्थायी रूप से हटा दें',
        _ => 'Restore or permanently remove deleted moments',
      },
      'logs' => switch (l10n.localeName) {
        'es' => 'Registros',
        'hi' => 'लॉग्स',
        _ => 'Logs',
      },
      'notes' => switch (l10n.localeName) {
        'es' => 'Notas',
        'hi' => 'नोट्स',
        _ => 'Notes',
      },
      'alarms permission required' => switch (l10n.localeName) {
        'es' => 'Permiso de alarmas requerido',
        'hi' => 'अलार्म अनुमति आवश्यक है',
        _ => 'Alarms Permission Required',
      },
      'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.' =>
        switch (l10n.localeName) {
          'es' =>
            'Para activar recordatorios con precisión cuando la aplicación está cerrada, NoteKar requiere el permiso de "Alarmas y recordatorios".',
          'hi' =>
            'ऐप बंद होने पर सटीक रूप से अनुस्मारक ट्रिगर करने के लिए, NoteKar को "अलार्म और अनुस्मारक" अनुमति की आवश्यकता होती है।',
          _ =>
            'To trigger reminders precisely when the app is closed, NoteKar requires the "Alarms & Reminders" permission.',
        },
      'grant permission' => switch (l10n.localeName) {
        'es' => 'Conceder permiso',
        'hi' => 'अनुमति दें',
        _ => 'Grant Permission',
      },
      'battery optimization active' => switch (l10n.localeName) {
        'es' => 'Optimización de batería activa',
        'hi' => 'बैटरी ऑप्टिमाइज़ेशन सक्रिय',
        _ => 'Battery Optimization Active',
      },
      'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.' =>
        switch (l10n.localeName) {
          'es' =>
            'Los limpiadores de batería agresivos en dispositivos de gama baja pueden cerrar NoteKar en segundo plano. Desactiva la optimización de batería para garantizar que los recordatorios se activen siempre.',
          'hi' =>
            'कम-एंड डिवाइस पर आक्रामक बैटरी क्लीनर बैकग्राउंड में NoteKar को बंद कर सकते हैं। यह सुनिश्चित करने के लिए कि अनुस्मारक हमेशा समय पर मिलें, बैटरी ऑप्टिमाइज़ेशन को अक्षम करें।',
          _ =>
            'Aggressive battery cleaners on low-end devices can kill NoteKar in the background. Disable battery optimization to guarantee reminders fire 100% of the time.',
        },
      'disable battery optimization' => switch (l10n.localeName) {
        'es' => 'Desactivar optimización de batería',
        'hi' => 'बैटरी ऑप्टिमाइज़ेशन अक्षम करें',
        _ => 'Disable Battery Optimization',
      },
      'sun' => switch (l10n.localeName) {
        'es' => 'Dom',
        'hi' => 'रवि',
        _ => 'Sun',
      },
      'mon' => switch (l10n.localeName) {
        'es' => 'Lun',
        'hi' => 'सोम',
        _ => 'Mon',
      },
      'tue' => switch (l10n.localeName) {
        'es' => 'Mar',
        'hi' => 'मंगल',
        _ => 'Tue',
      },
      'wed' => switch (l10n.localeName) {
        'es' => 'Mié',
        'hi' => 'बुध',
        _ => 'Wed',
      },
      'thu' => switch (l10n.localeName) {
        'es' => 'Jue',
        'hi' => 'गुरु',
        _ => 'Thu',
      },
      'fri' => switch (l10n.localeName) {
        'es' => 'Vie',
        'hi' => 'शुक्र',
        _ => 'Fri',
      },
      'sat' => switch (l10n.localeName) {
        'es' => 'Sáb',
        'hi' => 'शनि',
        _ => 'Sat',
      },
      'sunday' => switch (l10n.localeName) {
        'es' => 'Domingo',
        'hi' => 'रविवार',
        _ => 'Sunday',
      },
      'monday' => switch (l10n.localeName) {
        'es' => 'Lunes',
        'hi' => 'सोमवार',
        _ => 'Monday',
      },
      'tuesday' => switch (l10n.localeName) {
        'es' => 'Martes',
        'hi' => 'मंगलवार',
        _ => 'Tuesday',
      },
      'wednesday' => switch (l10n.localeName) {
        'es' => 'Miércoles',
        'hi' => 'बुधवार',
        _ => 'Wednesday',
      },
      'thursday' => switch (l10n.localeName) {
        'es' => 'Jueves',
        'hi' => 'गुरुवार',
        _ => 'Thursday',
      },
      'friday' => switch (l10n.localeName) {
        'es' => 'Viernes',
        'hi' => 'शुक्रवार',
        _ => 'Friday',
      },
      'saturday' => switch (l10n.localeName) {
        'es' => 'Sábado',
        'hi' => 'शनिवार',
        _ => 'Saturday',
      },
      'time' => switch (l10n.localeName) {
        'es' => 'Hora',
        'hi' => 'समय',
        _ => 'Time',
      },
      'message' => switch (l10n.localeName) {
        'es' => 'Mensaje',
        'hi' => 'संदेश',
        _ => 'Message',
      },
      'empty' => switch (l10n.localeName) {
        'es' => 'Vacío',
        'hi' => 'खाली',
        _ => 'Empty',
      },
      'set' => switch (l10n.localeName) {
        'es' => 'Establecido',
        'hi' => 'सेट',
        _ => 'Set',
      },
      'hour' => switch (l10n.localeName) {
        'es' => 'hora',
        'hi' => 'घंटा',
        _ => 'hour',
      },
      'hours' => switch (l10n.localeName) {
        'es' => 'horas',
        'hi' => 'घंटे',
        _ => 'hours',
      },
      'no message set (will show default reminder)' => switch (l10n
          .localeName) {
        'es' =>
          'Sin mensaje establecido (se mostrará el recordatorio predeterminado)',
        'hi' => 'कोई संदेश सेट नहीं है (डिफ़ॉल्ट अनुस्मारक दिखाया जाएगा)',
        _ => 'No message set (will show default reminder)',
      },
      'enter reminder message...' => switch (l10n.localeName) {
        'es' => 'Ingresar mensaje de recordatorio...',
        'hi' => 'अनुस्मारक संदेश दर्ज करें...',
        _ => 'Enter reminder message...',
      },
      'official repository moved' => switch (l10n.localeName) {
        'es' => 'Repositorio oficial movido',
        'hi' => 'आधिकारिक रिपॉजिटरी बदली',
        _ => 'Official Repository Moved',
      },
      'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:' =>
        switch (l10n.localeName) {
          'es' =>
            'Hemos migrado oficialmente nuestro código base a un nuevo hogar. Todos los lanzamientos, actualizaciones y problemas futuros se gestionarán aquí:',
          'hi' =>
            'हमने आधिकारिक तौर पर अपने कोडबेस को एक नए घर में स्थानांतरित कर दिया है। सभी भविष्य के रिलीज, अपडेट और मुद्दे यहां प्रबंधित किए जाएंगे:',
          _ =>
            'We have officially migrated our codebase to a new home. All future releases, updates, and issues will be managed here:',
        },
      'smaller, optimized apks' => switch (l10n.localeName) {
        'es' => 'APKs más pequeñas y optimizadas',
        'hi' => 'छोटे, अनुकूलित एपीके',
        _ => 'Smaller, Optimized APKs',
      },
      'access split-per-abi optimized binaries and google play appbundles directly from the release page.' =>
        switch (l10n.localeName) {
          'es' =>
            'Acceda a binarios optimizados por ABI y Google Play AppBundles directamente desde la página de lanzamiento.',
          'hi' =>
            'रिलीज़ पेज से सीधे स्प्लिट-प्रति-एबीआई अनुकूलित बायनेरिज़ और गूगल प्ले ऐपबंडल प्राप्त करें।',
          _ =>
            'Access split-per-ABI optimized binaries and Google Play AppBundles directly from the release page.',
        },
      'active issue tracking' => switch (l10n.localeName) {
        'es' => 'Seguimiento de problemas activo',
        'hi' => 'सक्रिय समस्या ट्रैकिंग',
        _ => 'Active Issue Tracking',
      },
      'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.' =>
        switch (l10n.localeName) {
          'es' =>
            'Envíe informes de errores, solicitudes de funciones y siga los cambios de código directamente en el nuevo rastreador de problemas.',
          'hi' =>
            'सीधे नए रिपॉजिटरी इशू ट्रैकर में बग रिपोर्ट, फीचर अनुरोध सबमिट करें और कोड परिवर्तनों का पालन करें।',
          _ =>
            'Submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.',
        },
      'automated security scans' => switch (l10n.localeName) {
        'es' => 'Escaneos de seguridad automáticos',
        'hi' => 'स्वचालित सुरक्षा स्कैन',
        _ => 'Automated Security Scans',
      },
      'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.' =>
        switch (l10n.localeName) {
          'es' =>
            'Todas las compilaciones ahora se someten a escaneos automáticos de CodeQL y comprobaciones de VirusTotal para garantizar la verificación y la seguridad.',
          'hi' =>
            'सत्यापन और सुरक्षा सुनिश्चित करने के लिए सभी निर्माण अब स्वचालित CodeQL स्कैन और VirusTotal जांच से गुजरते हैं।',
          _ =>
            'All builds now undergo automated CodeQL scans and VirusTotal checks to ensure verification and safety.',
        },
      'virustotal safety scan' => switch (l10n.localeName) {
        'es' => 'Escaneo de seguridad de VirusTotal',
        'hi' => 'VirusTotal सुरक्षा स्कैन',
        _ => 'VirusTotal Safety Scan',
      },
      'verified clean of malicious activity' => switch (l10n.localeName) {
        'es' => 'Verificado limpio de actividad maliciosa',
        'hi' => 'दुर्भावनापूर्ण गतिविधि से मुक्त सत्यापित',
        _ => 'Verified clean of malicious activity',
      },
      'ratio' => switch (l10n.localeName) {
        'es' => 'Proporción',
        'hi' => 'अनुपात',
        _ => 'Ratio',
      },
      '0 / 68 clean' => switch (l10n.localeName) {
        'es' => '0 / 68 limpio',
        'hi' => '0 / 68 स्वच्छ',
        _ => '0 / 68 clean',
      },
      'status' => switch (l10n.localeName) {
        'es' => 'Estado',
        'hi' => 'स्थिति',
        _ => 'Status',
      },
      'undetected' => switch (l10n.localeName) {
        'es' => 'No detectado',
        'hi' => 'अपरिचित (सुरक्षित)',
        _ => 'Undetected',
      },
      'last scan' => switch (l10n.localeName) {
        'es' => 'Último escaneo',
        'hi' => 'अंतिम स्कैन',
        _ => 'Last Scan',
      },
      'july 2026' => switch (l10n.localeName) {
        'es' => 'Julio de 2026',
        'hi' => 'जुलाई २०२६',
        _ => 'July 2026',
      },
      'signature' => switch (l10n.localeName) {
        'es' => 'Firma',
        'hi' => 'हस्ताक्षर',
        _ => 'Signature',
      },
      'developer key' => switch (l10n.localeName) {
        'es' => 'Clave del desarrollador',
        'hi' => 'डेवलपर कुंजी',
        _ => 'Developer Key',
      },
      'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.' =>
        switch (l10n.localeName) {
          'es' =>
            'Las compilaciones de NoteKar se someten a compilación automatizada del escáner CodeQL y escaneos locales de VirusTotal. Los binarios están firmados con nuestro certificado oficial para garantizar una integridad absoluta.',
          'hi' =>
            'NoteKar का प्रत्येक संकलन स्वचालित CodeQL स्कैनर संकलन और स्थानीय VirusTotal स्कैन से गुजरता है। पूर्ण अखंडता सुनिश्चित करने के लिए बाइनरी को हमारे आधिकारिक प्रमाणपत्र के साथ हस्ताक्षरित किया गया है।',
          _ =>
            'NoteKar builds undergo automated CodeQL scanner compilation and local VirusTotal scans. Binaries are signed with our official certificate to ensure absolute integrity.',
        },
      'vt report' => switch (l10n.localeName) {
        'es' => 'Informe de VT',
        'hi' => 'VT रिपोर्ट',
        _ => 'VT Report',
      },
      'sha-256 hashes' => switch (l10n.localeName) {
        'es' => 'Hashes SHA-256',
        'hi' => 'SHA-256 हैश',
        _ => 'SHA-256 Hashes',
      },
      'is notekar safe to use?' => switch (l10n.localeName) {
        'es' => '¿Es seguro usar NoteKar?',
        'hi' => 'क्या NoteKar उपयोग करने के लिए सुरक्षित है?',
        _ => 'Is NoteKar safe to use?',
      },
      'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.' =>
        switch (l10n.localeName) {
          'es' =>
            'Absolutamente. NoteKar es de código abierto y local primero. Para garantizar la máxima confianza y seguridad, cada versión compilada se carga automáticamente y se verifica limpia por más de 60 motores de seguridad a través de VirusTotal. Puede inspeccionar el informe de escaneo en vivo en Privacidad y seguridad.',
          'hi' =>
            'बिल्कुल। NoteKar ओपन-सोर्स और ऑफलाइन-फर्स्ट है। अधिकतम विश्वास और सुरक्षा की गारंटी के लिए, प्रत्येक संकलित रिलीज़ को स्वचालित रूप से अपलोड किया जाता है और VirusTotal के माध्यम से 60+ सुरक्षा इंजनों द्वारा स्वच्छ सत्यापित किया जाता है। आप गोपनीयता और सुरक्षा के तहत लाइव स्कैन रिपोर्ट का निरीक्षण कर सकते हैं।',
          _ =>
            'Absolutely. NoteKar is open-source and offline-first. To guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via VirusTotal. You can inspect the live scan report under Privacy & Security.',
        },
      'open link' => switch (l10n.localeName) {
        'es' => 'Abrir enlace',
        'hi' => 'लिंक खोलें',
        _ => 'Open Link',
      },
      'copy' => switch (l10n.localeName) {
        'es' => 'Copiar',
        'hi' => 'कॉपी',
        _ => 'Copy',
      },
      'repository link copied to clipboard' => switch (l10n.localeName) {
        'es' => 'Enlace del repositorio copiado al portapapeles',
        'hi' => 'रिपॉजिटरी लिंक क्लिपबोर्ड पर कॉपी किया गया',
        _ => 'Repository link copied to clipboard',
      },

      // Feature Conflict Dialog Keys
      'disable compact history?' => switch (l10n.localeName) {
        'es' => '¿Desactivar historial compacto?',
        'hi' => 'कॉम्पैक्ट इतिहास अक्षम करें?',
        _ => 'Disable Compact History?',
      },
      'turn off single numbers?' => switch (l10n.localeName) {
        'es' => '¿Desactivar números individuales?',
        'hi' => 'सिंगल नंबर बंद करें?',
        _ => 'Turn Off Single Numbers?',
      },
      'turn off & enable' => switch (l10n.localeName) {
        'es' => 'Desactivar y activar',
        'hi' => 'अक्षम करें और सक्रिय करें',
        _ => 'Turn Off & Enable',
      },
      'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.' =>
        switch (l10n.localeName) {
          'es' =>
            'La numeración secuencial (00–99) requiere espaciado estándar para mostrar insignias de 2 dígitos. Desactive el historial compacto para habilitar números.',
          'hi' =>
            'अनुक्रमिक एकल क्रमांकन (00–99) को 2-अंकीय बैज प्रदर्शित करने के लिए मानक पंक्ति रिक्ति की आवश्यकता होती है। सिंगल मोड में संख्याओं को सक्षम करने के लिए कॉम्पैक्ट इतिहास को बंद करें।',
          _ =>
            'Sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. Turn off Compact History to enable numbers in single mode.',
        },
      'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.' =>
        switch (l10n.localeName) {
          'es' =>
            'El historial compacto no se puede activar mientras la numeración de momentos individuales esté activa. Desactive los números para usar filas compactas.',
          'hi' =>
            'सिंगल मोमेंट नंबरिंग सक्रिय होने पर कॉम्पैक्ट इतिहास को सक्षम नहीं किया जा सकता है। कॉम्पैक्ट पंक्तियों का उपयोग करने के लिए सिंगल नंबर को बंद करें।',
          _ =>
            'Compact History cannot be enabled while Single Moment Numbering is active. Disable Single Numbers to use compact rows.',
        },

      // Single Numbering Keys
      'numbered single moments' => switch (l10n.localeName) {
        'es' => 'Momentos individuales numerados',
        'hi' => 'क्रमांकित एकल क्षण',
        _ => 'Numbered Single Moments',
      },
      'use numbers in single' => switch (l10n.localeName) {
        'es' => 'Usar números en individual',
        'hi' => 'सिंगल में नंबर का उपयोग करें',
        _ => 'Use Numbers in Single',
      },
      'reset daily' => switch (l10n.localeName) {
        'es' => 'Restablecer diariamente',
        'hi' => 'प्रतिदिन रीसेट करें',
        _ => 'Reset Daily',
      },
      'enable count on save' => switch (l10n.localeName) {
        'es' => 'Activar conteo al guardar',
        'hi' => 'सहेजने पर गिनती सक्षम करें',
        _ => 'Enable Count on Save',
      },
      'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.' =>
        switch (l10n.localeName) {
          'es' =>
            'Transforma tu historial con contadores secuenciales de 2 dígitos (00–99), reinicios diarios y un calendario estilo iOS.',
          'hi' =>
            'अनुक्रमिक 2-अंकीय काउंटरों (00–99), दैनिक मध्यरात्रि रीसेट और iOS शैली कैलेंडर के साथ अपने इतिहास को बदलें।',
          _ =>
            'Transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an iOS style calendar.',
        },
      'shows 00–99 counters instead of static icons in history.' => switch (l10n
          .localeName) {
        'es' =>
          'Muestra contadores de 00–99 en lugar de iconos estáticos en el historial.',
        'hi' => 'इतिहास में स्थिर आइकन के बजाय 00–99 काउंटर दिखाता है।',
        _ => 'Shows 00–99 counters instead of static icons in history.',
      },
      'restarts count at 00 every midnight while keeping past history intact.' =>
        switch (l10n.localeName) {
          'es' =>
            'Reinicia el conteo en 00 cada medianoche manteniendo el historial anterior.',
          'hi' =>
            'पिछले इतिहास को बरकरार रखते हुए हर मध्यरात्रि को 00 पर गिनती फिर से शुरू करता है।',
          _ =>
            'Restarts count at 00 every midnight while keeping past history intact.',
        },
      'shows sequential numbers (00, 01...) on the tap pulse animation.' =>
        switch (l10n.localeName) {
          'es' =>
            'Muestra números secuenciales (00, 01...) en la animación de pulsación.',
          'hi' =>
            'टैप पल्स एनिमेशन पर अनुक्रमिक संख्याएं (00, 01...) दिखाता है।',
          _ =>
            'Shows sequential numbers (00, 01...) on the tap pulse animation.',
        },

      _ => this,
    };
  }
}

// Complete _deTranslations Translation Map
const Map<String, String> _deTranslations = {
  '0 / 68 clean': '0 / 68 sauber',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      'Ein datenschutzorientiertes Offline-Serientracking und Tagebuch zur Unterstützung Ihrer Genesung.',
  'a quiet, offline-first way to mark moments the second they happen.':
      'Eine ruhige, lokale Möglichkeit, Momente im Augenblick festzuhalten.',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'Absolut. NoteKar ist Open Source und offline-first. Jede Version wird von 60+ Sicherheits-Engines über VirusTotal verifiziert.',
  'accent color': 'Akzentfarbe',
  'accentcolorcategory': 'Akzentfarbe',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      'Laden Sie ABI-optimierte Binärdateien direkt von der Release-Seite herunter.',
  'accessibility': 'Bedienungshilfen',
  'accessibilitycategory': 'Bedienungshilfen',
  'active issue tracking': 'Aktives Issue-Tracking',
  'adaptive engine': 'Adaptive Engine',
  'add a note': 'Notiz hinzufügen',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'Fügt Ihrem Startbildschirm eine übersichtliche Serienkarte hinzu und passt Widgets an.',
  'afternoon': 'Nachmittag',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'Deaktivieren Sie die Akku-Optimierung, um sicherzustellen, dass Erinnerungen immer zuverlässig ausgelöst werden.',
  'alarms permission required': 'Alarm-Berechtigung erforderlich',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      'Alle 21 Meilensteine von 1 Tag bis 10 Jahren, fundiert in Neurowissenschaft und Verhaltenspsychologie.',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'Alle Builds durchlaufen automatisierte CodeQL- und VirusTotal-Prüfungen zur Gewährleistung der Sicherheit.',
  'allow notifications': 'Benachrichtigungen zulassen',
  'amethyst': 'Amethyst',
  'ancient': 'Antike',
  'angry': 'Wütend',
  'animal kingdom': 'Tierreich',
  'anxious': 'Ängstlich / Besorgt',
  'app icons': 'App-Symbole',
  'app language': 'App-Sprache',
  'app lock timing': 'App-Sperrzeit',
  'app lock will not turn on': 'App-Sperre lässt sich nicht aktivieren',
  'app notices are not appearing': 'App-Benachrichtigungen erscheinen nicht',
  'app theme': 'App-Farbschema',
  'appiconscategory': 'App-Symbole',
  'army elite. every clean day is a battle fought and won.':
      'Armee-Elite. Jeder saubere Tag ist eine gewonnene Schlacht.',
  'at': 'um',
  'attack on titan': 'Attack on Titan',
  'aurora': 'Aurora',
  'automated security scans': 'Automatisierte Sicherheits-Scans',
  'back up data': 'Daten sichern',
  'backup & export': 'Sicherung & Export',
  'backup & restore': 'Sicherung & Wiederherstellung',
  'backup import failed': 'Sicherungsimport fehlgeschlagen',
  'backup import found no new moments':
      'Sicherungsimport ergab keine neuen Momente',
  'backupexportcategory': 'Sicherung & Export',
  'battery optimization active': 'Akku-Optimierung aktiv',
  'ben 10': 'Ben 10',
  'bleach': 'Bleach',
  'bored': 'Gelangweilt',
  'boredom': 'Langeweile',
  'bushido code. master of the self.': 'Bushido-Kodex. Meister des Selbst.',
  'can i restore deleted moments?':
      'Kann ich gelöschte Momente wiederherstellen?',
  'cancel': 'Abbrechen',
  'capture': 'Erfassung',
  'capturecategory': 'Erfassung',
  'changelog': 'Änderungsprotokoll',
  'changelogtitle': 'Änderungsprotokoll',
  'chess mastery': 'Schach-Meisterschaft',
  'choose milestone theme': 'Meilenstein-Design wählen',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'Wählen Sie den narrativen Stil für Ihre Meilensteine. Jedes Thema ist psychologisch kuratiert.',
  'choose your preferred interface language':
      'Wählen Sie Ihre bevorzugte Oberflächensprache',
  'civilian to the one above all.': 'Zivilist bis zum Einen über Allen.',
  'clan': 'Klan',
  'clear search': 'Suche löschen',
  'close': 'Schließen',
  'code geass': 'Code Geass',
  'compact history': 'Kompakter Verlauf',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'Der kompakte Verlauf kann nicht aktiviert werden, solange die Einzelzählung aktiv ist. Deaktivieren Sie die Einzelziffern, um kompakte Zeilen zu verwenden.',
  'configure settings': 'Einstellungen anpassen',
  'confirm': 'Bestätigen',
  'confirm delete': 'Löschen bestätigen',
  'copy': 'Kopieren',
  'cosmic exploration. every clean day is light-years gained.':
      'Kosmische Erkundung. Jeder saubere Tag bringt Lichtjahre ein.',
  'crimson': 'Karminrot',
  'current message': 'Aktuelle Nachricht',
  'cursed spirit to satoru gojo.': 'Fluchgeist bis Satoru Gojo.',
  'custom start date': 'Benutzerdefiniertes Startdatum',
  'daily reminder': 'Tägliche Erinnerung',
  'daily reminder message': 'Tägliche Erinnerungsnachricht',
  'data & backup': 'Daten & Sicherung',
  'day of month': 'Tag des Monats',
  'days of week': 'Wochentage',
  'death note': 'Death Note',
  'delete': 'Löschen',
  'delete all moments?': 'Alle Momente löschen?',
  'delete permanently?': 'Endgültig löschen?',
  'deleted in moment': 'IN-Moment gelöscht',
  'deleted out moment': 'OUT-Moment gelöscht',
  'deleted single moment': 'SINGLE-Moment gelöscht',
  'demon slayer': 'Demon Slayer',
  'developer key': 'Entwickler-Schlüssel',
  'developer options': 'Entwickleroptionen',
  'diagnostics': 'Diagnose',
  'diagnosticscategory': 'Diagnose',
  'disable battery optimization': 'Akku-Optimierung deaktivieren',
  'disable compact history?': 'Kompakten Verlauf deaktivieren?',
  'display': 'Anzeige',
  'displaycategory': 'Anzeige',
  'done': 'Fertig',
  'dragon ball': 'Dragon Ball',
  'e-rank sung jinwoo to shadow monarch.':
      'E-Rang Sung Jinwoo bis zum Schattenmonarchen.',
  'east blue coby to the pirate king gol d. roger.':
      'East Blue Corby bis zum Piratenkönig Gol D. Roger.',
  'edit': 'Bearbeiten',
  'edit message': 'Nachricht bearbeiten',
  'emerald': 'Smaragd',
  'empty': 'Leer',
  'empty trash?': 'Papierkorb leeren?',
  'enable count on save': 'Zähler beim Speichern anzeigen',
  'enable sobriety mode': 'Nüchternheitsmodus aktivieren',
  'english': 'Englisch',
  'enter reminder message...': 'Erinnerungstext eingeben...',
  'evening': 'Abend',
  'extended duration': 'Erweiterte Dauer',
  'fatigue': 'Ermüdung',
  'fri': 'Fr',
  'friday': 'Freitag',
  'friends': 'Freunde',
  'from': 'Von',
  'fullmetal alchemist': 'Fullmetal Alchemist',
  'german': 'Deutsch',
  'get started': 'Loslegen',
  'gintama': 'Gintama',
  'grant permission': 'Berechtigung erteilen',
  'grey matter to alien x.': 'Graue Eminenz bis Alien X.',
  'happy': 'Glücklich',
  'harry potter': 'Harry Potter',
  'hindi': 'Hindi',
  'history': 'Verlauf',
  'hour': 'Stunde',
  'hours': 'Stunden',
  'html editor to turing award winner.':
      'HTML-Editor bis zum Turing-Preisträger.',
  'hunter x hunter': 'Hunter x Hunter',
  'imperial': 'Kaiserlich',
  'inactivity reminder': 'Inaktivitäts-Erinnerung',
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
  'live icon motion looks slow or delayed':
      'Live-Icon-Bewegung wirkt verzögert',
  'live icon motion will not turn on':
      'Live-Icon-Bewegung lässt sich nicht aktivieren',
  'load older moments': 'Ältere Momente laden',
  'location': 'Ort',
  'logging reminder': 'Protokoll-Erinnerung',
  'logs': 'Protokolle',
  'loneliness': 'Einsamkeit',
  'lonely': 'Einsam',
  'magikarp to the creator god arceus.':
      'Karpador bis zum Schöpfergott Arceus.',
  'manage moment notes': 'Moment-Notizen verwalten',
  'marvel universe': 'Marvel-Universum',
  'matsuda to the shinigami king.': 'Matsuda bis zum König der Todesgötter.',
  'medieval royalty. rise from serf to sovereign.':
      'Mittelalterlicher Adel. Vom Knecht zum Herrscher.',
  'message': 'Nachricht',
  'midnight': 'Mitternacht',
  'milestone theme': 'Meilenstein-Design',
  'milestones': 'Meilensteine',
  'mineta to all might prime.': 'Mineta bis All Might in Bestform.',
  'minimal moment options': 'Minimale Moment-Optionen',
  'moisture farmer to the chosen one.':
      'Feuchtigkeitsfarmer bis zum Auserwählten.',
  'moment options': 'Moment-Optionen',
  'moments': 'Momente',
  'momentscategory': 'Momente',
  'mon': 'Mo',
  'monastic journey. silence, stillness, and vows.':
      'Mönchische Reise. Stille, Ruhe und Gelübde.',
  'monday': 'Montag',
  'monk': 'Mönch',
  'monthly reminder': 'Monatliche Erinnerung',
  'monthly reminder message': 'Monatliche Erinnerungsnachricht',
  'morning': 'Morgen',
  'muggle to merlin.': 'Muggel bis Merlin.',
  'murata to yoriichi tsugikuni.': 'Murata bis Yoriichi Tsugikuni.',
  'my hero academia': 'My Hero Academia',
  'naruto': 'Naruto',
  'navy': 'Marine',
  'night': 'Nacht',
  'no note': 'Keine Notiz',
  'no relapses recorded yet!': 'Noch keine Rückfälle erfasst!',
  'no results': 'Keine Ergebnisse',
  'no results found': 'Keine Ergebnisse gefunden',
  'none': 'Keine',
  'not set: using last log or relapse tag':
      'Nicht festgelegt: Letzter Eintrag oder Rückfall-Tag wird verwendet',
  'note on click': 'Notiz beim Tippen',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'NoteKar-Builds durchlaufen automatisierte CodeQL- und lokale VirusTotal-Scans.',
  'notekar is offline': 'NoteKar ist offline',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKar speichert Momente privat auf diesem Gerät. Sicherungen kontrollieren Sie selbst.',
  'notes': 'Notizen',
  'numbered single moments': 'Nummerierte Einzelmomente',
  'official repository moved': 'Offizielles Repository umgezogen',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      'Offline-Analyse Ihrer protokollierten Momente. Keine Daten verlassen Ihr Gerät.',
  'okay': 'OK',
  'one piece': 'One Piece',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      'Nur Momente mit dem Tag #relapse setzen die Serie zurück. Deaktivieren, um bei jedem neuen Eintrag zurückzusetzen.',
  'open link': 'Link öffnen',
  'peak risk window': 'Höchstes Risikofenster',
  'phoenix': 'Phönix',
  'pokemon': 'Pokémon',
  'priest willibald to thors the troll of jom.':
      'Priester Willibald bis Thors der Troll von Jom.',
  'privacy & security': 'Datenschutz & Sicherheit',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'Datenschutzorientiertes Serientracking und Tagebuch. Alle Daten bleiben auf Ihrem Gerät.',
  'privacysecuritycategory': 'Datenschutz & Sicherheit',
  'pure titan to the founder ymir fritz.':
      'Reiner Titan bis zur Ur-Gründerin Ymir Fritz.',
  'ratio': 'Verhältnis',
  'recent messages': 'Letzte Nachrichten',
  'recently deleted': 'KÜRZLICH GELÖSCHT',
  'remind if inactive for': 'Erinnern bei Inaktivität seit',
  'reminders': 'Erinnerungen',
  'reminders & notifications': 'Erinnerungen & Benachrichtigungen',
  'repository link copied to clipboard':
      'Repository-Link in Zwischenablage kopiert',
  'reset': 'Zurücksetzen',
  'reset daily': 'Täglich zurücksetzen',
  'reset on relapse tag only': 'Nur bei Rückfall-Tag zurücksetzen',
  'resetcategory': 'Zurücksetzen',
  'restarts count at 00 every midnight while keeping past history intact.':
      'Startet die Zählung jeden Tag um Mitternacht bei 00 neu, während vergangene Einträge erhalten bleiben.',
  'restore all': 'Alle wiederherstellen',
  'restore all moments?': 'Alle Momente wiederherstellen?',
  'restore deleted moments': 'Gelöschte Momente wiederherstellen',
  'review backup': 'Sicherung überprüfen',
  'review history': 'Verlauf überprüfen',
  'rpg / minecraft': 'RPG / Minecraft',
  'russian': 'Russisch',
  'sad': 'Traurig',
  'samurai': 'Samurai',
  'sapphire': 'Saphir',
  'sat': 'Sa',
  'saturday': 'Samstag',
  'save': 'Speichern',
  'save a moment': 'Moment speichern',
  'scholar\'s mate victim to magnus carlsen.':
      'Schäfermatt-Opfer bis Magnus Carlsen.',
  'science': 'Wissenschaft',
  'seafaring odyssey. chart new waters and never look back.':
      'Seefahrt-Odyssee. Erkunden Sie neue Gewässer und blicken Sie nicht zurück.',
  'search notes': 'Notizen durchsuchen',
  'select date': 'Datum wählen',
  'select date and time': 'Datum und Uhrzeit auswählen',
  'select your preferred language for the application.':
      'Wählen Sie Ihre bevorzugte Sprache für die Anwendung.',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      'Die fortlaufende Einzelnummerierung (00–99) erfordert Standard-Zeilenabstand zur Anzeige der 2-stelligen Abzeichen. Deaktivieren Sie den kompakten Verlauf, um Ziffern zu aktivieren.',
  'set': 'Festgelegt',
  'set sobriety start date': 'Nüchternheitsstartdatum festlegen',
  'settings': 'Einstellungen',
  'sha-256 hashes': 'SHA-256-Hashes',
  'shinpachi to utsuro.': 'Shinpachi bis Utsuro.',
  'shirley to emperor lelouch vi britannia.':
      'Shirley bis Kaiser Lelouch vi Britannia.',
  'shows 00–99 counters instead of static icons in history.':
      'Zeigt 00–99 Zähler anstelle von statischen Symbolen im Verlauf an.',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'Zeigt fortlaufende Nummern (00, 01...) auf der Tap-Puls-Animation an.',
  'signature': 'Signatur',
  'single mode': 'Einzel-Modus',
  'skip': 'Überspringen',
  'smaller, optimized apks': 'Kleinere, optimierte APKs',
  'sobriety companion': 'Nüchternheitsbegleiter',
  'sobriety trigger analysis': 'Nüchternheits-Auslöser-Analyse',
  'social media': 'Soziale Medien',
  'social_media': 'Soziale Medien',
  'solo leveling': 'Solo Leveling',
  'space': 'Weltraum',
  'spanish': 'Spanisch',
  'star wars': 'Star Wars',
  'start logging': 'Protokollieren starten',
  'status': 'Status',
  'streak mode': 'Serien-Modus',
  'streak reset logic': 'Serien-Rücksetzlogik',
  'stress': 'Stress',
  'stressed': 'Gestresst',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'Reichen Sie Fehlerberichte und Feature-Wünsche direkt im neuen Issue-Tracker ein.',
  'sun': 'So',
  'sunday': 'Sonntag',
  'sunset': 'Sonnenuntergang',
  'system default': 'Systemstandard',
  'tech career': 'Technik-Karriere',
  'teddy bear kon to yhwach the almighty.':
      'Plüschbär Kon bis Yhwach der Allmächtige.',
  'the current features on this page are under beta stage.':
      'Die Funktionen auf dieser Seite befinden sich im Beta-Stadium.',
  'theme mode': 'Design-Modus',
  'theme style': 'Design-Stil',
  'this moment will be erased forever.':
      'Dieser Moment wird unwiderruflich gelöscht.',
  'this week': 'Diese Woche',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'Dadurch werden alle Momente im Papierkorb endgültig gelöscht. Dieser Vorgang kann nicht rückgängig gemacht werden.',
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
  'top mood': 'Häufigste Stimmung',
  'top trigger': 'Häufigster Auslöser',
  'total relapses': 'Rückfälle insgesamt',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      'Verwandeln Sie Ihren Verlauf mit 2-stelligen Zählern (00–99), täglichen Mitternachtsrücksetzungen und einem Kalender im iOS-Stil.',
  'trash bin': 'Papierkorb',
  'trigger analysis': 'Auslöser-Analyse',
  'trigger diary': 'Auslöser-Tagebuch',
  'tue': 'Di',
  'tuesday': 'Dienstag',
  'turn off & enable': 'Deaktivieren & Aktivieren',
  'turn off single numbers?': 'Einzelne Ziffern deaktivieren?',
  'two-way mode': 'Zwei-Wege-Modus',
  'undetected': 'Nicht erkannt (Sauber)',
  'update check failed': 'Update-Prüfung fehlgeschlagen',
  'use numbers in single': 'Nummern in Einzelmomenten',
  'verified clean of malicious activity':
      'Nachweislich frei von schädlicher Software',
  'view': 'Anzeigen',
  'view all milestones': 'Alle Meilensteine anzeigen',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      'Sehen Sie Einblicke in Rückfallmuster, Top-Stimmungen und Phasen höchster Anfälligkeit.',
  'vinland saga': 'Vinland Saga',
  'virustotal safety scan': 'VirusTotal-Sicherheitsüberprüfung',
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
  'what\'s new': 'Neuigkeiten',
  'what\'s new in notekar': 'Neuigkeiten in NoteKar',
  'whatsnewtitle': 'Neuigkeiten',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'Beim Protokollieren mit aktiviertem Nüchternheitsmodus können Sie Stimmung und Auslöser markieren.',
  'wooden shovel to creative mode god.':
      'Holzschaufel bis zum Gott des Kreativmodus.',
  'yamcha to the omni-king zeno.': 'Yamchu bis zum Allkönig Zeno.',
  'yoki to the ultimate truth.': 'Yoki bis zur ultimativen Wahrheit.',
  'your clean streak is active and running.': 'Ihre Serie ist aktiv und läuft.',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'Ihre Daten sind zu 100 % privat und bleiben offline auf diesem Gerät.',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'Ihr Startbildschirm zeigt eine Live-Serienkarte mit Meilensteinabzeichen.',
};

// Complete _jaTranslations Translation Map
const Map<String, String> _jaTranslations = {
  '0 / 68 clean': '0 / 68 安全',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      '回復の歩みを支援するために構築された、完全オフラインの日数追跡・記録日記。',
  'a quiet, offline-first way to mark moments the second they happen.':
      '起きたその瞬間に素早く記録できる、静かな完全オフラインアプリ。',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'もちろんです。NoteKarはオープンソースかつ完全オフライン動作です。60以上のセキュリティエンジンで安全性が確認されています。',
  'accent color': 'アクセントカラー',
  'accentcolorcategory': 'アクセントカラー',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      '最適化されたバイナリをリリース画面から直接入手できます。',
  'accessibility': 'アクセシビリティ',
  'accessibilitycategory': 'アクセシビリティ',
  'active issue tracking': 'アクティブな課題管理',
  'adaptive engine': 'アダプティブエンジン',
  'add a note': 'メモを追加',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'ホーム画面にクリーンな日数カードを追加し、ウィジェットを最適化します。',
  'afternoon': '昼・午後',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'リマインダーを確実に届けるため、バッテリー最適化をオフに設定してください。',
  'alarms permission required': 'アラーム権限が必要です',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      '神経科学と行動心理学に基づく、1日から10年までの全21のマイルストーン。',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'すべてのビルドでCodeQLおよびVirusTotalによる自動安全検証を実施しています。',
  'allow notifications': '通知を許可',
  'amethyst': 'アメジスト',
  'ancient': 'エンシェント',
  'angry': '怒り',
  'animal kingdom': 'アニマルキングダム',
  'anxious': '不安・焦り',
  'app icons': 'アプリアイコン',
  'app language': 'アプリの言語',
  'app lock timing': 'アプリロックのタイミング',
  'app lock will not turn on': 'アプリロックが有効になりません',
  'app notices are not appearing': 'アプリの通知が表示されません',
  'app theme': 'アプリのテーマ',
  'appiconscategory': 'アプリアイコン',
  'army elite. every clean day is a battle fought and won.':
      '精鋭部隊。日々の継続が勝利への前進。',
  'at': '',
  'attack on titan': '進撃の巨人',
  'aurora': 'オーロラ',
  'automated security scans': '自動セキュリティスキャン',
  'back up data': 'データをバックアップ',
  'backup & export': 'バックアップとエクスポート',
  'backup & restore': 'バックアップと復元',
  'backup import failed': 'バックアップのインポートに失敗しました',
  'backup import found no new moments': 'バックアップに取り込む新しいモーメントは見つかりませんでした',
  'backupexportcategory': 'バックアップとエクスポート',
  'battery optimization active': 'バッテリー最適化が有効です',
  'ben 10': 'ベン10',
  'bleach': 'BLEACH',
  'bored': '退屈',
  'boredom': '退屈',
  'bushido code. master of the self.': '武士道。自己の修練。',
  'can i restore deleted moments?': '削除したモーメントは復元できますか？',
  'cancel': 'キャンセル',
  'capture': '記録モード',
  'capturecategory': '記録モード',
  'changelog': '変更履歴',
  'changelogtitle': '変更履歴',
  'chess mastery': 'チェスマスター',
  'choose milestone theme': 'マイルストーンテーマを選択',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'マイルストーン名の物語スタイルを選択してください。',
  'choose your preferred interface language': '希望の表示言語を選択してください',
  'civilian to the one above all.': '一般市民からワン・アバブ・オールへ。',
  'clan': 'クラン',
  'clear search': '検索をクリア',
  'close': '閉じる',
  'code geass': 'コードギアス',
  'compact history': 'コンパクト履歴',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'シングルモーメント番号が有効な間はコンパクト履歴を有効にできません。コンパクト行を使用するにはシングル番号を無効にしてください。',
  'configure settings': '設定を開く',
  'confirm': '確認',
  'confirm delete': '削除前に確認',
  'copy': 'コピー',
  'cosmic exploration. every clean day is light-years gained.':
      '宇宙探査。日々の積み重ねが光年単位の進歩。',
  'crimson': 'クリムゾン',
  'current message': '現在のメッセージ',
  'cursed spirit to satoru gojo.': '呪霊から五条悟へ。',
  'custom start date': 'カスタム開始日',
  'daily reminder': 'デイリーリマインダー',
  'daily reminder message': '毎日のリマインダー文',
  'data & backup': 'データとバックアップ',
  'day of month': '日付（毎月）',
  'days of week': '曜日',
  'death note': 'デスノート',
  'delete': '削除',
  'delete all moments?': 'すべてのモーメントを削除しますか？',
  'delete permanently?': '完全に削除しますか？',
  'deleted in moment': 'INモーメントを削除しました',
  'deleted out moment': 'OUTモーメントを削除しました',
  'deleted single moment': 'SINGLEモーメントを削除しました',
  'demon slayer': '鬼滅の刃',
  'developer key': '開発者キー',
  'developer options': '開発者向けオプション',
  'diagnostics': '診断情報',
  'diagnosticscategory': '診断情報',
  'disable battery optimization': 'バッテリー最適化を無効化',
  'disable compact history?': 'コンパクト履歴を無効にしますか？',
  'display': '画面表示',
  'displaycategory': '画面表示',
  'done': '完了',
  'dragon ball': 'ドラゴンボール',
  'e-rank sung jinwoo to shadow monarch.': 'E級ハンター水篠旬から影の君主へ。',
  'east blue coby to the pirate king gol d. roger.':
      'イーストブルーのコビーから海賊王ゴール・D・ロジャーへ。',
  'edit': '編集',
  'edit message': 'メッセージを編集',
  'emerald': 'エメラルド',
  'empty': '未設定',
  'empty trash?': 'ゴミ箱を空にしますか？',
  'enable count on save': '保存時のカウント表示を有効化',
  'enable sobriety mode': 'ソブリエティモードを有効化',
  'english': '英語',
  'enter reminder message...': '通知メッセージを入力...',
  'evening': '夕方',
  'extended duration': '詳細な経過時間',
  'fatigue': '倦怠感',
  'fri': '金',
  'friday': '金曜日',
  'friends': '交友関係',
  'from': '開始:',
  'fullmetal alchemist': '鋼の錬金術師',
  'german': 'ドイツ語',
  'get started': '始める',
  'gintama': '銀魂',
  'grant permission': '権限を許可',
  'grey matter to alien x.': 'グレイマターからエイリアンXへ。',
  'happy': '喜び',
  'harry potter': 'ハリー・ポッター',
  'hindi': 'ヒンディー語',
  'history': '履歴',
  'hour': '時間',
  'hours': '時間',
  'html editor to turing award winner.': 'HTMLエディタからチューリング賞受賞者へ。',
  'hunter x hunter': 'HUNTER×HUNTER',
  'imperial': 'インペリアル',
  'inactivity reminder': '未記録リマインダー',
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
  'live icon motion looks slow or delayed': 'ライブアイコンの動作が遅く感じられます',
  'live icon motion will not turn on': 'ライブアイコンのアニメーションが有効になりません',
  'load older moments': '過去のモーメントを読み込む',
  'location': '特定の場所',
  'logging reminder': '記録リマインダー',
  'logs': 'ログ',
  'loneliness': '孤独感',
  'lonely': '孤独',
  'magikarp to the creator god arceus.': 'コイキングから創造神アルセウスへ。',
  'manage moment notes': 'モーメントのメモ管理',
  'marvel universe': 'マーベル・ユニバース',
  'matsuda to the shinigami king.': '松田から死神大王へ。',
  'medieval royalty. rise from serf to sovereign.': '中世の王権。平民から君主への道。',
  'message': 'メッセージ',
  'midnight': 'ミッドナイト',
  'milestone theme': 'マイルストーンのテーマ',
  'milestones': 'マイルストーン',
  'mineta to all might prime.': '峰田から全盛期のオールマイトへ。',
  'minimal moment options': 'シンプルなモーメント操作',
  'moisture farmer to the chosen one.': '水分農夫から選ばれし者へ。',
  'moment options': 'モーメント操作',
  'moments': 'モーメント',
  'momentscategory': 'モーメント',
  'mon': '月',
  'monastic journey. silence, stillness, and vows.': '修道者の旅路。静寂と誓い。',
  'monday': '月曜日',
  'monk': '僧侶',
  'monthly reminder': 'マンスリーリマインダー',
  'monthly reminder message': '毎月のリマインダー文',
  'morning': '朝',
  'muggle to merlin.': 'マグルからマーリンへ。',
  'murata to yoriichi tsugikuni.': '村田から継国縁壱へ。',
  'my hero academia': '僕のヒーローアカデミア',
  'naruto': 'NARUTO',
  'navy': 'ネイビー',
  'night': '夜',
  'no note': 'メモなし',
  'no relapses recorded yet!': 'まだ再発の記録はありません！',
  'no results': '結果なし',
  'no results found': '結果が見つかりません',
  'none': 'なし',
  'not set: using last log or relapse tag': '未設定: 最後の記録または再発タグを使用',
  'note on click': 'タップでメモを表示',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'NoteKarのビルドはCodeQLおよびVirusTotalで検査され、公式証明書で署名されています。',
  'notekar is offline': 'NoteKarはオフラインです',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKarはお使いの端末内にのみ安全にデータを保存します。バックアップファイルはお客様自身で管理できます。',
  'notes': 'メモ',
  'numbered single moments': '番号付きシングルモーメント',
  'official repository moved': '公式リポジトリ移転のお知らせ',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      '記録されたモーメントのオフライン分析。データが端末外へ送信されることはありません。',
  'okay': 'OK',
  'one piece': 'ワンピース',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      '#relapse タグが付いた記録のみが日数をリセットします。新しい記録すべてでリセットする場合はオフにしてください。',
  'open link': 'リンクを開く',
  'peak risk window': '最も注意が必要な時間帯',
  'phoenix': 'フェニックス',
  'pokemon': 'ポケモン',
  'priest willibald to thors the troll of jom.': 'ヴィリバルドからヨームの戦鬼トールズへ。',
  'privacy & security': 'プライバシーとセキュリティ',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'プライバシー重視の日数追跡と記録日記。すべてのデータはお使いの端末内に保存されます。',
  'privacysecuritycategory': 'プライバシーとセキュリティ',
  'pure titan to the founder ymir fritz.': '無垢の巨人から始祖ユミルへ。',
  'ratio': '検証スコア',
  'recent messages': '最近のメッセージ',
  'recently deleted': '最近削除したアイテム',
  'remind if inactive for': '指定時間記録がない場合に通知:',
  'reminders': 'リマインダー',
  'reminders & notifications': 'リマインダーと通知',
  'repository link copied to clipboard': 'リポジトリのリンクをクリップボードにコピーしました',
  'reset': 'リセット',
  'reset daily': '毎日リセット',
  'reset on relapse tag only': '再発タグ時のみリセット',
  'resetcategory': 'リセット',
  'restarts count at 00 every midnight while keeping past history intact.':
      '過去の履歴を保持したまま、毎晩午前0時にカウントを00に再設定します。',
  'restore all': 'すべて復元',
  'restore all moments?': 'すべてのモーメントを復元しますか？',
  'restore deleted moments': '削除したモーメントの復元',
  'review backup': 'バックアップを確認',
  'review history': '履歴を確認',
  'rpg / minecraft': 'RPG / マイクラ',
  'russian': 'ロシア語',
  'sad': '悲しみ',
  'samurai': '侍',
  'sapphire': 'サファイア',
  'sat': '土',
  'saturday': '土曜日',
  'save': '保存',
  'save a moment': 'モーメントを保存',
  'scholar\'s mate victim to magnus carlsen.': 'メイト初心者からマグヌス・カールセンへ。',
  'science': 'サイエンス',
  'seafaring odyssey. chart new waters and never look back.':
      '航海の叙事詩。未知の海原へ舵を取り前へ。',
  'search notes': 'メモを検索',
  'select date': '日付を選択',
  'select date and time': '日付と時刻を選択',
  'select your preferred language for the application.':
      'アプリケーションの言語を選択してください。',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      '連続シングル番号（00〜99）は2桁バッジを表示するために標準の行間隔が必要です。シングルモードで番号を使用するにはコンパクト履歴を無効にしてください。',
  'set': '設定済み',
  'set sobriety start date': '開始日時を設定',
  'settings': '設定',
  'sha-256 hashes': 'SHA-256 ハッシュ',
  'shinpachi to utsuro.': '新八から虚へ。',
  'shirley to emperor lelouch vi britannia.': 'シャーリーから皇帝ルルーシュ・ヴィ・ブリタニアへ。',
  'shows 00–99 counters instead of static icons in history.':
      '履歴内で固定アイコンの代わりに00〜99のカウンターを表示します。',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'タップ時のアニメーションに連続番号（00, 01...）を表示します。',
  'signature': '電子署名',
  'single mode': 'シングル記録モード',
  'skip': 'スキップ',
  'smaller, optimized apks': '軽量・最適化されたパッケージ',
  'sobriety companion': 'ソブリエティ・コンパニオン',
  'sobriety trigger analysis': 'トリガー傾向分析',
  'social media': 'SNS',
  'social_media': 'SNS',
  'solo leveling': '俺だけレベルアップな件',
  'space': '宇宙',
  'spanish': 'スペイン語',
  'star wars': 'スター・ウォーズ',
  'start logging': '記録を始める',
  'status': '状態',
  'streak mode': '日数記録モード',
  'streak reset logic': '日数リセット設定',
  'stress': 'ストレス',
  'stressed': 'ストレス',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'バグ報告や機能要望を直接投稿できます。',
  'sun': '日',
  'sunday': '日曜日',
  'sunset': 'サンセット',
  'system default': 'システム標準',
  'tech career': 'テックキャリア',
  'teddy bear kon to yhwach the almighty.': 'コンから全知全能のユーハバッハへ。',
  'the current features on this page are under beta stage.':
      'このページの機能は現在ベータ版です。',
  'theme mode': 'テーマモード',
  'theme style': 'テーマのスタイル',
  'this moment will be erased forever.': 'このモーメントは完全に消去されます。',
  'this week': '今週',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'ゴミ箱内のすべてのモーメントが完全に削除されます。この操作は取り消せません。',
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
  'top mood': '主な気分',
  'top trigger': '主なトリガー',
  'total relapses': '記録した再発回数',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      '2桁の連続カウンター（00〜99）、毎日の自動リセット、iOSスタイルのカレンダーで履歴をすっきり整理できます。',
  'trash bin': 'ゴミ箱',
  'trigger analysis': 'トリガー分析',
  'trigger diary': 'トリガー日記',
  'tue': '火',
  'tuesday': '火曜日',
  'turn off & enable': '無効化して有効にする',
  'turn off single numbers?': 'シングル番号を無効にしますか？',
  'two-way mode': 'IN/OUT 2方向モード',
  'undetected': '脅威なし (安全)',
  'update check failed': 'アップデート確認に失敗しました',
  'use numbers in single': 'シングルで番号を使用',
  'verified clean of malicious activity': '悪意ある動作のない安全性を検証済み',
  'view': '表示',
  'view all milestones': 'すべてのマイルストーンを見る',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      '再発パターンの傾向、主な気分、注意すべき時間帯を確認できます。',
  'vinland saga': 'ヴィンランド・サガ',
  'virustotal safety scan': 'VirusTotal セキュリティ検証',
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
  'what\'s new': '新機能',
  'what\'s new in notekar': 'NoteKarの新機能',
  'whatsnewtitle': '新機能',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'ソブリエティモード有効時に記録する際、気分やトリガーをタグ付けできます。',
  'wooden shovel to creative mode god.': '木のシャベルからクリエイティブモードの神へ。',
  'yamcha to the omni-king zeno.': 'ヤムチャから全王様へ。',
  'yoki to the ultimate truth.': 'ヨキから真理へ。',
  'your clean streak is active and running.': '継続日数が進行中です。',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'データは100%プライベートで端末内に留まります。',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'ホーム画面にマイルストーンバッジ付きの日数カードが表示されます。',
};

// Complete _ruTranslations Translation Map
const Map<String, String> _ruTranslations = {
  '0 / 68 clean': '0 / 68 безопасно',
  'a privacy-first, offline clean streak tracker and relapse diary built to empower your recovery journey.':
      'Конфиденциальный офлайн-трекер трезвости и дневник для поддержки вашего пути.',
  'a quiet, offline-first way to mark moments the second they happen.':
      'Простой локальный способ фиксировать моменты в секунду их свершения.',
  'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.':
      'Абсолютно. NoteKar имеет открытый исходный код и работает полностью офлайн. Надежность подтверждена 60+ антивирусными системами.',
  'accent color': 'Цвет акцента',
  'accentcolorcategory': 'Цвет акцента',
  'access split-per-abi optimized binaries and google play appbundles directly from the release page.':
      'Загружайте оптимизированные сборки прямо со страницы релизов.',
  'accessibility': 'Специальные возможности',
  'accessibilitycategory': 'Специальные возможности',
  'active issue tracking': 'Отслеживание задач и багов',
  'adaptive engine': 'Адаптивный движок',
  'add a note': 'Добавить заметку',
  'adds a clean streak card to your home screen and adapts home screen widgets.':
      'Добавляет карточку серии на главный экран и оптимизирует виджеты.',
  'afternoon': 'День',
  'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.':
      'Отключите оптимизацию батареи, чтобы гарантировать надежную доставку напоминаний.',
  'alarms permission required': 'Требуется разрешение на будильники',
  'all 21 milestones from 1 day to 10 years, rooted in neuroscience, addiction recovery research, and behavioural psychology. names shown in your current theme.':
      'Все 21 достижение от 1 дня до 10 лет, основанные на исследованиях нейробиологии.',
  'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.':
      'Все сборки проходят автоматические проверки CodeQL и VirusTotal для гарантии чистоты кода.',
  'allow notifications': 'Разрешить уведомления',
  'amethyst': 'Аметист',
  'ancient': 'Древность',
  'angry': 'Гнев',
  'animal kingdom': 'Царство животных',
  'anxious': 'Тревога',
  'app icons': 'Иконки приложения',
  'app language': 'Язык приложения',
  'app lock timing': 'Время блокировки приложения',
  'app lock will not turn on': 'Блокировка приложения не включается',
  'app notices are not appearing': 'Уведомления приложения не отображаются',
  'app theme': 'Цветовая тема',
  'appiconscategory': 'Иконки приложения',
  'army elite. every clean day is a battle fought and won.':
      'Армейская элита. Каждый день — выигранная битва.',
  'at': 'в',
  'attack on titan': 'Атака титанов',
  'aurora': 'Аврора',
  'automated security scans': 'Автоматические проверки безопасности',
  'back up data': 'Резервное копирование',
  'backup & export': 'Резервное копирование и экспорт',
  'backup & restore': 'Резервное копирование и восстановление',
  'backup import failed': 'Ошибка импорта резервной копии',
  'backup import found no new moments':
      'В резервной копии не найдено новых моментов',
  'backupexportcategory': 'Резервное копирование и экспорт',
  'battery optimization active': 'Включена оптимизация батареи',
  'ben 10': 'Бен 10',
  'bleach': 'Блич',
  'bored': 'Скука',
  'boredom': 'Скука',
  'bushido code. master of the self.': 'Кодекс бусидо. Власть над собой.',
  'can i restore deleted moments?': 'Можно ли восстановить удаленные моменты?',
  'cancel': 'Отмена',
  'capture': 'Запись',
  'capturecategory': 'Запись',
  'changelog': 'Список изменений',
  'changelogtitle': 'Список изменений',
  'chess mastery': 'Мастерство в шахматах',
  'choose milestone theme': 'Выбрать тему достижений',
  'choose the narrative style for your milestone names. each theme is psychologically curated to match a different self-image and motivation style.':
      'Выберите стиль названий для ваших достижений.',
  'choose your preferred interface language':
      'Выберите предпочтительный язык интерфейса',
  'civilian to the one above all.': 'От обывателя до Всевышнего.',
  'clan': 'Клан',
  'clear search': 'Очистить поиск',
  'close': 'Закрыть',
  'code geass': 'Код Гиас',
  'compact history': 'Компактная история',
  'compact history cannot be enabled while single moment numbering is active. disable single numbers to use compact rows.':
      'Компактная история не может быть включена при активной нумерации одиночных моментов. Отключите одиночные номера для компактных строк.',
  'configure settings': 'Настроить параметры',
  'confirm': 'Подтвердить',
  'confirm delete': 'Подтверждение удаления',
  'copy': 'Копировать',
  'cosmic exploration. every clean day is light-years gained.':
      'Космические исследования. Каждый чистый день — световые годы вперед.',
  'crimson': 'Багровый',
  'current message': 'Текущее сообщение',
  'cursed spirit to satoru gojo.': 'От проклятого духа до Сатору Годжо.',
  'custom start date': 'Своя дата начала',
  'daily reminder': 'Ежедневное напоминание',
  'daily reminder message': 'Текст ежедневного напоминания',
  'data & backup': 'Данные и резервные копии',
  'day of month': 'Число месяца',
  'days of week': 'Дни недели',
  'death note': 'Тетрадь смерти',
  'delete': 'Удалить',
  'delete all moments?': 'Удалить все моменты?',
  'delete permanently?': 'Удалить навсегда?',
  'deleted in moment': 'Момент IN удален',
  'deleted out moment': 'Момент OUT удален',
  'deleted single moment': 'Момент SINGLE удален',
  'demon slayer': 'Клинок, рассекающий демонов',
  'developer key': 'Ключ разработчика',
  'developer options': 'Параметры разработчика',
  'diagnostics': 'Диагностика',
  'diagnosticscategory': 'Диагностика',
  'disable battery optimization': 'Отключить оптимизацию батареи',
  'disable compact history?': 'Отключить компактную историю?',
  'display': 'Отображение',
  'displaycategory': 'Отображение',
  'done': 'Готово',
  'dragon ball': 'Драконий жемчуг',
  'e-rank sung jinwoo to shadow monarch.':
      'От Сон Джинву E-ранга до Владыки Теней.',
  'east blue coby to the pirate king gol d. roger.':
      'От Коби из Ист Блю до Короля пиратов Гол Д. Роджера.',
  'edit': 'Редактировать',
  'edit message': 'Редактировать сообщение',
  'emerald': 'Изумруд',
  'empty': 'Пусто',
  'empty trash?': 'Очистить корзину?',
  'enable count on save': 'Показывать счетчик при сохранении',
  'enable sobriety mode': 'Включить режим трезвости',
  'english': 'Английский',
  'enter reminder message...': 'Введите текст напоминания...',
  'evening': 'Вечер',
  'extended duration': 'Расширенная длительность',
  'fatigue': 'Утомление',
  'fri': 'Пт',
  'friday': 'Пятница',
  'friends': 'Друзья',
  'from': 'С',
  'fullmetal alchemist': 'Стальной алхимик',
  'german': 'Немецкий',
  'get started': 'Начать',
  'gintama': 'Гинтама',
  'grant permission': 'Предоставить разрешение',
  'grey matter to alien x.': 'От Гуманоида до Пришельца Икс.',
  'happy': 'Радость',
  'harry potter': 'Гарри Поттер',
  'hindi': 'Хинди',
  'history': 'История',
  'hour': 'час',
  'hours': 'часов',
  'html editor to turing award winner.':
      'От HTML-редактора до лауреата премии Тьюринга.',
  'hunter x hunter': 'Хантер х Хантер',
  'imperial': 'Империал',
  'inactivity reminder': 'Напоминание при неактивности',
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
  'live icon motion looks slow or delayed':
      'Анимация иконки работает с задержкой',
  'live icon motion will not turn on': 'Анимация иконки не включается',
  'load older moments': 'Загрузить более старые моменты',
  'location': 'Место',
  'logging reminder': 'Напоминание о записи',
  'logs': 'Записи',
  'loneliness': 'Одиночество',
  'lonely': 'Одиночество',
  'magikarp to the creator god arceus.': 'От Мэджикарпа до создателя Аркеуса.',
  'manage moment notes': 'Управление заметками',
  'marvel universe': 'Вселенная Marvel',
  'matsuda to the shinigami king.': 'От Мацуды до Короля синигами.',
  'medieval royalty. rise from serf to sovereign.':
      'Средневековая знать. От простолюдина до государя.',
  'message': 'Сообщение',
  'midnight': 'Полночь',
  'milestone theme': 'Тема достижений',
  'milestones': 'Достижения',
  'mineta to all might prime.': 'От Минеты до Всемогущего на пике сил.',
  'minimal moment options': 'Минимальные действия',
  'moisture farmer to the chosen one.':
      'От фермера-влагодобытчика до Избранного.',
  'moment options': 'Параметры момента',
  'moments': 'Моменты',
  'momentscategory': 'Моменты',
  'mon': 'Пн',
  'monastic journey. silence, stillness, and vows.':
      'Монашеский путь. Безмолвие и стойкость.',
  'monday': 'Понедельник',
  'monk': 'Монах',
  'monthly reminder': 'Ежемесячное напоминание',
  'monthly reminder message': 'Текст ежемесячного напоминания',
  'morning': 'Утро',
  'muggle to merlin.': 'От магла до Мерлина.',
  'murata to yoriichi tsugikuni.': 'От Мураты до Ёриити Цугикуни.',
  'my hero academia': 'Моя геройская академия',
  'naruto': 'Наруто',
  'navy': 'Флот',
  'night': 'Ночь',
  'no note': 'Нет заметки',
  'no relapses recorded yet!': 'Срывов пока не зафиксировано!',
  'no results': 'Нет результатов',
  'no results found': 'Ничего не найдено',
  'none': 'Нет',
  'not set: using last log or relapse tag':
      'Не задано: используется последняя запись или тег срыва',
  'note on click': 'Заметка по нажатию',
  'notekar': 'NoteKar',
  'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.':
      'Сборки NoteKar компилируются со сканированием CodeQL и проверяются в VirusTotal.',
  'notekar is offline': 'NoteKar работает офлайн',
  'notekar stores moments privately on this device. backups are files you control.':
      'NoteKar хранит моменты конфиденциально на этом устройстве. Резервные копии находятся под вашим полным контролем.',
  'notes': 'Заметки',
  'numbered single moments': 'Нумерованные одиночные моменты',
  'official repository moved': 'Официальный репозиторий перемещен',
  'offline analysis of your logged relapse moments. no data leaves your device.':
      'Офлайн-анализ ваших записей. Никакие данные не покидают устройство.',
  'okay': 'ОК',
  'one piece': 'Ван Пис',
  'only moments tagged #relapse reset the streak. turn off to reset on any new log.':
      'Только записи с тегом #relapse сбрасывают серию. Отключите, чтобы сбрасывать при любой новой записи.',
  'open link': 'Открыть ссылку',
  'peak risk window': 'Пиковое время риска',
  'phoenix': 'Феникс',
  'pokemon': 'Покемон',
  'priest willibald to thors the troll of jom.':
      'От священника Виллибальда до Торса Йомского тролля.',
  'privacy & security': 'Конфиденциальность и безопасность',
  'privacy-first streak tracking and relapse diary. all data stays on your device. existing logs are never altered.':
      'Конфиденциальное отслеживание серии и дневник. Все данные остаются на вашем устройстве.',
  'privacysecuritycategory': 'Конфиденциальность и безопасность',
  'pure titan to the founder ymir fritz.':
      'От обычного титана до прародительницы Имир Фриц.',
  'ratio': 'Результат',
  'recent messages': 'Недавние сообщения',
  'recently deleted': 'НЕДАВНО УДАЛЕННЫЕ',
  'remind if inactive for': 'Напомнить при отсутствии записей:',
  'reminders': 'Напоминания',
  'reminders & notifications': 'Напоминания и уведомления',
  'repository link copied to clipboard':
      'Ссылка на репозиторий скопирована в буфер обмена',
  'reset': 'Сброс',
  'reset daily': 'Сбрасывать ежедневно',
  'reset on relapse tag only': 'Сброс только по тегу срыва',
  'resetcategory': 'Сброс',
  'restarts count at 00 every midnight while keeping past history intact.':
      'Перезапускает счет с 00 каждую полночь, сохраняя предыдущую историю.',
  'restore all': 'Восстановить все',
  'restore all moments?': 'Восстановить все моменты?',
  'restore deleted moments': 'Восстановить удаленные моменты',
  'review backup': 'Проверить резервную копию',
  'review history': 'Просмотреть историю',
  'rpg / minecraft': 'RPG / Майнкрафт',
  'russian': 'Русский',
  'sad': 'Грусть',
  'samurai': 'Самурай',
  'sapphire': 'Сапфир',
  'sat': 'Сб',
  'saturday': 'Суббота',
  'save': 'Сохранить',
  'save a moment': 'Сохранить момент',
  'scholar\'s mate victim to magnus carlsen.':
      'От жертвы детского мата до Магнуса Карлсена.',
  'science': 'Наука',
  'seafaring odyssey. chart new waters and never look back.':
      'Морская одиссея. Открывайте новые горизонты.',
  'search notes': 'Поиск заметок',
  'select date': 'Выбрать дату',
  'select date and time': 'Выбрать дату и время',
  'select your preferred language for the application.':
      'Выберите язык для приложения.',
  'sequential single numbering (00–99) requires standard row spacing to display 2-digit badges. turn off compact history to enable numbers in single mode.':
      'Последовательная нумерация (00–99) требует стандартных отступов строк для отображения 2-значных значков. Отключите компактную историю, чтобы включить нумерацию.',
  'set': 'Установлено',
  'set sobriety start date': 'Установить дату начала',
  'settings': 'Настройки',
  'sha-256 hashes': 'Хэши SHA-256',
  'shinpachi to utsuro.': 'От Синпати до Уцуро.',
  'shirley to emperor lelouch vi britannia.':
      'От Ширли до императора Лелуша ви Британия.',
  'shows 00–99 counters instead of static icons in history.':
      'Отображает счетчики 00–99 вместо статических иконок в истории.',
  'shows sequential numbers (00, 01...) on the tap pulse animation.':
      'Показывает порядковые номера (00, 01...) на анимации нажатия.',
  'signature': 'Подпись',
  'single mode': 'Одиночный режим',
  'skip': 'Пропустить',
  'smaller, optimized apks': 'Оптимизированные пакеты APK',
  'sobriety companion': 'Трекер трезвости',
  'sobriety trigger analysis': 'Анализ триггеров',
  'social media': 'Соцсети',
  'social_media': 'Соцсети',
  'solo leveling': 'Поднятие уровня в одиночку',
  'space': 'Космос',
  'spanish': 'Испанский',
  'star wars': 'Звездные войны',
  'start logging': 'Начать запись',
  'status': 'Статус',
  'streak mode': 'Режим серии',
  'streak reset logic': 'Логика сброса серии',
  'stress': 'Стресс',
  'stressed': 'Стресс',
  'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.':
      'Отправляйте отчеты об ошибках и предложения в трекер нового репозитория.',
  'sun': 'Вс',
  'sunday': 'Воскресенье',
  'sunset': 'Закат',
  'system default': 'Системный',
  'tech career': 'Карьера в IT',
  'teddy bear kon to yhwach the almighty.':
      'От плюшевого Кона до Всемогущего Яхве.',
  'the current features on this page are under beta stage.':
      'Функции на этой странице находятся на стадии бета-тестирования.',
  'theme mode': 'Режим оформления',
  'theme style': 'Стиль темы',
  'this moment will be erased forever.': 'Этот момент будет удален навсегда.',
  'this week': 'На этой неделе',
  'this will permanently delete all moments in the trash. this action cannot be undone.':
      'Все моменты в корзине будут удалены навсегда. Это действие нельзя отменить.',
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
  'top mood': 'Главное настроение',
  'top trigger': 'Главный триггер',
  'total relapses': 'Всего срывов',
  'transform your history with sequential 2-digit counters (00–99), daily midnight resets, and an ios style calendar.':
      'Организуйте историю с помощью 2-значных счетчиков (00–99), ежедневного сброса в полночь и календаря в стиле iOS.',
  'trash bin': 'Корзина',
  'trigger analysis': 'Анализ триггеров',
  'trigger diary': 'Дневник триггеров',
  'tue': 'Вт',
  'tuesday': 'Вторник',
  'turn off & enable': 'Отключить и включить',
  'turn off single numbers?': 'Отключить одиночные номера?',
  'two-way mode': 'Двусторонний режим',
  'undetected': 'Угроз не обнаружено (Чисто)',
  'update check failed': 'Не удалось проверить обновления',
  'use numbers in single': 'Номера в одиночных',
  'verified clean of malicious activity':
      'Проверено на отсутствие вредоносного ПО',
  'view': 'Просмотреть',
  'view all milestones': 'Все достижения',
  'view your relapse pattern insights, top moods, and peak vulnerability windows.':
      'Просматривайте статистику триггеров, преобладающие настроения и уязвимые часы.',
  'vinland saga': 'Сага о Винланде',
  'virustotal safety scan': 'Проверка безопасности VirusTotal',
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
  'what\'s new': 'Что нового',
  'what\'s new in notekar': 'Что нового в NoteKar',
  'whatsnewtitle': 'Что нового',
  'when logging a moment with sobriety mode on, you can tag mood (bored, anxious, lonely...) and trigger (social media, late night...). these are stored as hashtags in the note for full backwards compatibility.':
      'При создании записи можно указать настроение и триггер.',
  'wooden shovel to creative mode god.':
      'От деревянной лопаты до бога Творческого режима.',
  'yamcha to the omni-king zeno.': 'От Ямчи до Короля Всего Зено.',
  'yoki to the ultimate truth.': 'От Йоки до абсолютной Истины.',
  'your clean streak is active and running.': 'Ваша непрерывная серия активна.',
  'your data is 100% private and stays offline on this device. enabling this does not alter any existing logs.':
      'Ваши данные на 100% конфиденциальны и остаются на устройстве.',
  'your home screen will show a live streak card with milestone badges. the home widget will adapt to show reset and diary buttons.':
      'На главном экране появится карточка с серией и значками достижений.',
};
