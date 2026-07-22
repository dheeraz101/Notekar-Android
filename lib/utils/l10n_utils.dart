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
      "what's new" || 'whats new' || 'whatsnewtitle' => switch (l10n.localeName) {
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
      'backup & export' || 'backup & restore' || 'data & backup' || 'backup-export' || 'backupexportcategory' => l10n.backupExportCategory,
      'privacy & security' || 'privacy-security' || 'privacysecuritycategory' => l10n.privacySecurityCategory,
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
      'a quiet, offline-first way to mark moments the second they happen.' => switch (l10n.localeName) {
        'es' => 'Una forma silenciosa y local de registrar momentos al instante.',
        'hi' => 'क्षणों को तुरंत रिकॉर्ड करने का एक शांत, ऑफ़लाइन-पहला तरीका।',
        _ => 'A quiet, offline-first way to mark moments the second they happen.',
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
        'es' => 'La importación de copia de seguridad no encontró nuevos momentos',
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
      'app lock appears after the notification panel' => switch (l10n.localeName) {
        'es' => 'El bloqueo de app aparece después del panel de notificaciones',
        'hi' => 'ऐप लॉक नोटिफिकेशन पैनल के बाद दिखाई देता है',
        _ => 'App Lock appears after the notification panel',
      },
      'notekar stores moments privately on this device. backups are files you control.' => switch (l10n.localeName) {
        'es' => 'NoteKar guarda momentos de forma privada en este dispositivo. Las copias de seguridad son archivos que tú controlas.',
        'hi' => 'NoteKar इस डिवाइस पर क्षणों को निजी रूप से संग्रहीत करता है। बैकअप वे फाइलें हैं जिन्हें आप नियंत्रित करते हैं।',
        _ => 'NoteKar stores moments privately on this device. Backups are files you control.',
      },
      'select your preferred language for the application.' => switch (l10n.localeName) {
        'es' => 'Selecciona tu idioma preferido para la aplicación.',
        'hi' => 'एप्लिकेशन के लिए अपनी पसंदीदा भाषा चुनें।',
        _ => 'Select your preferred language for the application.',
      },
      'the current features on this page are under beta stage.' => switch (l10n.localeName) {
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
      'this will return all items currently in the trash to your history.' => switch (l10n.localeName) {
        'es' => 'Esto devolverá todos los elementos actualmente en la papelera a su historial.',
        'hi' => 'यह वर्तमान में कचरा पात्र में मौजूद सभी वस्तुओं को आपके इतिहास में वापस कर देगा।',
        _ => 'This will return all items currently in the trash to your history.',
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
      'this will permanently delete all moments in the trash. this action cannot be undone.' => switch (l10n.localeName) {
        'es' => 'Esto eliminará permanentemente todos los momentos de la papelera. Esta acción no se puede deshacer.',
        'hi' => 'यह कचरा पात्र के सभी क्षणों को स्थायी रूप से हटा देगा। यह क्रिया पूर्ववत नहीं की जा सकती।',
        _ => 'This will permanently delete all moments in the trash. This action cannot be undone.',
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
      'restore or permanently remove deleted moments' => switch (l10n.localeName) {
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
      'to trigger reminders precisely when the app is closed, notekar requires the "alarms & reminders" permission.' => switch (l10n.localeName) {
        'es' => 'Para activar recordatorios con precisión cuando la aplicación está cerrada, NoteKar requiere el permiso de "Alarmas y recordatorios".',
        'hi' => 'ऐप बंद होने पर सटीक रूप से अनुस्मारक ट्रिगर करने के लिए, NoteKar को "अलार्म और अनुस्मारक" अनुमति की आवश्यकता होती है।',
        _ => 'To trigger reminders precisely when the app is closed, NoteKar requires the "Alarms & Reminders" permission.',
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
      'aggressive battery cleaners on low-end devices can kill notekar in the background. disable battery optimization to guarantee reminders fire 100% of the time.' => switch (l10n.localeName) {
        'es' => 'Los limpiadores de batería agresivos en dispositivos de gama baja pueden cerrar NoteKar en segundo plano. Desactiva la optimización de batería para garantizar que los recordatorios se activen siempre.',
        'hi' => 'कम-एंड डिवाइस पर आक्रामक बैटरी क्लीनर बैकग्राउंड में NoteKar को बंद कर सकते हैं। यह सुनिश्चित करने के लिए कि अनुस्मारक हमेशा समय पर मिलें, बैटरी ऑप्टिमाइज़ेशन को अक्षम करें।',
        _ => 'Aggressive battery cleaners on low-end devices can kill NoteKar in the background. Disable battery optimization to guarantee reminders fire 100% of the time.',
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
      'no message set (will show default reminder)' => switch (l10n.localeName) {
        'es' => 'Sin mensaje establecido (se mostrará el recordatorio predeterminado)',
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
      'we have officially migrated our codebase to a new home. all future releases, updates, and issues will be managed here:' => switch (l10n.localeName) {
        'es' => 'Hemos migrado oficialmente nuestro código base a un nuevo hogar. Todos los lanzamientos, actualizaciones y problemas futuros se gestionarán aquí:',
        'hi' => 'हमने आधिकारिक तौर पर अपने कोडबेस को एक नए घर में स्थानांतरित कर दिया है। सभी भविष्य के रिलीज, अपडेट और मुद्दे यहां प्रबंधित किए जाएंगे:',
        _ => 'We have officially migrated our codebase to a new home. All future releases, updates, and issues will be managed here:',
      },
      'smaller, optimized apks' => switch (l10n.localeName) {
        'es' => 'APKs más pequeñas y optimizadas',
        'hi' => 'छोटे, अनुकूलित एपीके',
        _ => 'Smaller, Optimized APKs',
      },
      'access split-per-abi optimized binaries and google play appbundles directly from the release page.' => switch (l10n.localeName) {
        'es' => 'Acceda a binarios optimizados por ABI y Google Play AppBundles directamente desde la página de lanzamiento.',
        'hi' => 'रिलीज़ पेज से सीधे स्प्लिट-प्रति-एबीआई अनुकूलित बायनेरिज़ और गूगल प्ले ऐपबंडल प्राप्त करें।',
        _ => 'Access split-per-ABI optimized binaries and Google Play AppBundles directly from the release page.',
      },
      'active issue tracking' => switch (l10n.localeName) {
        'es' => 'Seguimiento de problemas activo',
        'hi' => 'सक्रिय समस्या ट्रैकिंग',
        _ => 'Active Issue Tracking',
      },
      'submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.' => switch (l10n.localeName) {
        'es' => 'Envíe informes de errores, solicitudes de funciones y siga los cambios de código directamente en el nuevo rastreador de problemas.',
        'hi' => 'सीधे नए रिपॉजिटरी इशू ट्रैकर में बग रिपोर्ट, फीचर अनुरोध सबमिट करें और कोड परिवर्तनों का पालन करें।',
        _ => 'Submit bug reports, feature requests, and follow code changes directly in the new repository issue tracker.',
      },
      'automated security scans' => switch (l10n.localeName) {
        'es' => 'Escaneos de seguridad automáticos',
        'hi' => 'स्वचालित सुरक्षा स्कैन',
        _ => 'Automated Security Scans',
      },
      'all builds now undergo automated codeql scans and virustotal checks to ensure verification and safety.' => switch (l10n.localeName) {
        'es' => 'Todas las compilaciones ahora se someten a escaneos automáticos de CodeQL y comprobaciones de VirusTotal para garantizar la verificación y la seguridad.',
        'hi' => 'सत्यापन और सुरक्षा सुनिश्चित करने के लिए सभी निर्माण अब स्वचालित CodeQL स्कैन और VirusTotal जांच से गुजरते हैं।',
        _ => 'All builds now undergo automated CodeQL scans and VirusTotal checks to ensure verification and safety.',
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
      'notekar builds undergo automated codeql scanner compilation and local virustotal scans. binaries are signed with our official certificate to ensure absolute integrity.' => switch (l10n.localeName) {
        'es' => 'Las compilaciones de NoteKar se someten a compilación automatizada del escáner CodeQL y escaneos locales de VirusTotal. Los binarios están firmados con nuestro certificado oficial para garantizar una integridad absoluta.',
        'hi' => 'NoteKar का प्रत्येक संकलन स्वचालित CodeQL स्कैनर संकलन और स्थानीय VirusTotal स्कैन से गुजरता है। पूर्ण अखंडता सुनिश्चित करने के लिए बाइनरी को हमारे आधिकारिक प्रमाणपत्र के साथ हस्ताक्षरित किया गया है।',
        _ => 'NoteKar builds undergo automated CodeQL scanner compilation and local VirusTotal scans. Binaries are signed with our official certificate to ensure absolute integrity.',
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
      'absolutely. notekar is open-source and offline-first. to guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via virustotal. you can inspect the live scan report under privacy & security.' => switch (l10n.localeName) {
        'es' => 'Absolutamente. NoteKar es de código abierto y local primero. Para garantizar la máxima confianza y seguridad, cada versión compilada se carga automáticamente y se verifica limpia por más de 60 motores de seguridad a través de VirusTotal. Puede inspeccionar el informe de escaneo en vivo en Privacidad y seguridad.',
        'hi' => 'बिल्कुल। NoteKar ओपन-सोर्स और ऑफलाइन-फर्स्ट है। अधिकतम विश्वास और सुरक्षा की गारंटी के लिए, प्रत्येक संकलित रिलीज़ को स्वचालित रूप से अपलोड किया जाता है और VirusTotal के माध्यम से 60+ सुरक्षा इंजनों द्वारा स्वच्छ सत्यापित किया जाता है। आप गोपनीयता और सुरक्षा के तहत लाइव स्कैन रिपोर्ट का निरीक्षण कर सकते हैं।',
        _ => 'Absolutely. NoteKar is open-source and offline-first. To guarantee maximum trust and safety, every compiled release is automatically uploaded and verified clean by 60+ anti-malware engines via VirusTotal. You can inspect the live scan report under Privacy & Security.',
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
