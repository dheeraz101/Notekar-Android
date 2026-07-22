# 🌐 Translating NoteKar Android

We want NoteKar to be accessible to people all over the world in their native language! NoteKar uses standard Flutter ARB (Application Resource Bundle) files for internationalization (`l10n`).

---

## 🚀 How to Add a New Translation

You don't need deep programming experience to help translate NoteKar!

### Step 1: Copy the Template File
1. Locate [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb).
2. Create a copy of the file in `lib/l10n/` named after your target language code (`app_<language_code>.arb`).

**Examples:**
* 🇪🇸 Spanish: `lib/l10n/app_es.arb`
* 🇮🇳 Hindi: `lib/l10n/app_hi.arb`
* 🇩🇪 German: `lib/l10n/app_de.arb`
* 🇫🇷 French: `lib/l10n/app_fr.arb`
* 🇯🇵 Japanese: `lib/l10n/app_ja.arb`

---

### Step 2: Translate the Text
Open your new file and change the values on the right side of each line to your language:

```json
{
  "@@locale": "es",
  "appTitle": "NoteKar",
  "settingsTitle": "Ajustes",
  "historyTitle": "Historial",
  "whatsNewTitle": "Novedades en NoteKar",
  "changelogTitle": "Registro de cambios",
  "displayCategory": "Pantalla",
  "accentColorCategory": "Color de acento",
  "appIconsCategory": "Iconos de la aplicación",
  "captureCategory": "Captura",
  "momentsCategory": "Momentos",
  "backupExportCategory": "Copia de seguridad y exportación",
  "privacySecurityCategory": "Privacidad y seguridad",
  "accessibilityCategory": "Accesibilidad",
  "resetCategory": "Restablecer",
  "diagnosticsCategory": "Diagnóstico",
  "loadOlderMoments": "Cargar momentos anteriores",
  "noResultsFound": "Sin resultados",
  "clearSearch": "Borrar búsqueda",
  "cancel": "Cancelar",
  "save": "Guardar",
  "confirm": "Confirmar",
  "delete": "Eliminar"
}
```

> **Important**: Do not change the key names (the left side, e.g. `"settingsTitle"`). Only translate the string values on the right side.

---

## ⚡ Dynamic Translation Engine (`lib/utils/l10n_utils.dart`)

For text elements that cannot easily be moved into ARB files (like onboarding pages, dynamic FAQ lists, settings guides, and toast overlays), NoteKar uses a **Dynamic Translation Engine** located in [`lib/utils/l10n_utils.dart`](lib/utils/l10n_utils.dart).

Any string can call `.localized(context)` to automatically check the user's active locale and match it to a translation.

### How to add dynamic translations:
1. Open [`lib/utils/l10n_utils.dart`](lib/utils/l10n_utils.dart).
2. Locate the `switch (key.toLowerCase())` block.
3. Add your English string key in lowercase, and specify translations for Hindi (`hi`) and Spanish (`es`):
```dart
      'your english text' => switch (l10n.localeName) {
        'es' => 'Su texto en español',
        'hi' => 'आपका हिंदी पाठ',
        _ => 'Your English text',
      },
```

---

### Step 3: Test and Submit

1. (Optional) Run `flutter gen-l10n` to verify your translation generates cleanly.
2. Commit your updated `.arb` and `.dart` files:
   ```bash
   git add lib/l10n/app_es.arb lib/utils/l10n_utils.dart
   git commit -m "i18n: add Spanish translations and dynamic labels (es)"
   ```
3. Open a **Pull Request** on GitHub!

---

## 💖 Thank You!

Your contribution will help thousands of users enjoy a private, offline timestamp logger in their native language.
