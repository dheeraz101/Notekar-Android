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
      "what's new in notekar" || "what's new" || 'whats new' || 'whatsnewtitle' => l10n.whatsNewTitle,
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
      _ => this,
    };
  }
}
