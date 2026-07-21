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
      _ => this,
    };
  }
}
