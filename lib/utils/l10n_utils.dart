import 'package:flutter/material.dart';
import 'package:notekar/l10n/app_localizations.dart';

extension LocalizedString on String {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return this;

    // Normalize string key mapping
    final key = trim().replaceAll('’', "'");
    return switch (key.toLowerCase()) {
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
      _ => this,
    };
  }
}
