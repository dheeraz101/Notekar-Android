# 🌐 Translating NoteKar Android

We want NoteKar to be accessible to everyone worldwide in their native language! NoteKar uses
standard Flutter ARB (Application Resource Bundle) files for internationalization (`l10n`) alongside
a high-performance **Dynamic Translation Dictionary Engine** (`lib/utils/l10n_utils.dart`).

---

## 🌟 Currently Supported Languages (7 Live)

| Language      | Locale Code | Native Name | Status |
|:--------------|:-----------:|:------------|:------:|
| 🇬🇧 English  |    `en`     | English     | ✅ Live |
| 🇫🇷 French   |    `fr`     | Français    | ✅ Live |
| 🇪🇸 Spanish  |    `es`     | Español     | ✅ Live |
| 🇮🇳 Hindi    |    `hi`     | हिन्दी      | ✅ Live |
| 🇩🇪 German   |    `de`     | Deutsch     | ✅ Live |
| 🇯🇵 Japanese |    `ja`     | 日本語         | ✅ Live |
| 🇷🇺 Russian  |    `ru`     | Русский     | ✅ Live |

---

## 🚀 52+ Target Upcoming Languages (Community Help Wanted!)

You can claim any of the upcoming languages below and submit a Pull Request!

<details>
<summary><b>Click to view all 52 upcoming target languages</b></summary>

- [ ] 🇸🇦 **Arabic** (`ar`) — العربية
- [ ] 🇧🇷 **Portuguese** (`pt`) — Português
- [ ] 🇮🇹 **Italian** (`it`) — Italiano
- [ ] 🇨🇳 **Chinese (Simplified)** (`zh-CN`) — 简体中文
- [ ] 🇹🇼 **Chinese (Traditional)** (`zh-TW`) — 繁體中文
- [ ] 🇰🇷 **Korean** (`ko`) — 한국어
- [ ] 🇹🇷 **Turkish** (`tr`) — Türkçe
- [ ] 🇳🇱 **Dutch** (`nl`) — Nederlands
- [ ] 🇵🇱 **Polish** (`pl`) — Polski
- [ ] 🇸🇪 **Swedish** (`sv`) — Svenska
- [ ] 🇮🇩 **Indonesian** (`id`) — Bahasa Indonesia
- [ ] 🇻🇳 **Vietnamese** (`vi`) — Tiếng Việt
- [ ] 🇹🇭 **Thai** (`th`) — ไทย
- [ ] 🇺🇦 **Ukrainian** (`uk`) — Українська
- [ ] 🇬🇷 **Greek** (`el`) — Ελληνικά
- [ ] 🇨🇿 **Czech** (`cs`) — Čeština
- [ ] 🇷🇴 **Romanian** (`ro`) — Română
- [ ] 🇭🇺 **Hungarian** (`hu`) — Magyar
- [ ] 🇩🇰 **Danish** (`da`) — Dansk
- [ ] 🇫🇮 **Finnish** (`fi`) — Suomi
- [ ] 🇳🇴 **Norwegian** (`no`) — Norsk
- [ ] 🇮🇱 **Hebrew** (`he`) — עברית
- [ ] 🇧🇩 **Bengali** (`bn`) — বাংলা
- [ ] 🇮🇳 **Marathi** (`mr`) — मराठी
- [ ] 🇮🇳 **Telugu** (`te`) — తెలుగు
- [ ] 🇮🇳 **Tamil** (`ta`) — தமிழ்
- [ ] 🇮🇳 **Gujarati** (`gu`) — ગુજરાતી
- [ ] 🇵🇰 **Urdu** (`ur`) — اردو
- [ ] 🇮🇳 **Kannada** (`kn`) — ಕನ್ನಡ
- [ ] 🇮🇳 **Malayalam** (`ml`) — മലയാളം
- [ ] 🇮🇳 **Punjabi** (`pa`) — ਪੰਜਾਬੀ
- [ ] 🇰🇪 **Swahili** (`sw`) — Kiswahili
- [ ] 🇮🇷 **Persian** (`fa`) — فارسی
- [ ] 🇲🇾 **Malay** (`ms`) — Bahasa Melayu
- [ ] 🇵🇭 **Tagalog / Filipino** (`tl`) — Filipino
- [ ] 🇸🇰 **Slovak** (`sk`) — Slovenčina
- [ ] 🇧🇬 **Bulgarian** (`bg`) — Български
- [ ] 🇭🇷 **Croatian** (`hr`) — Hrvatski
- [ ] 🇷🇸 **Serbian** (`sr`) — Српски
- [ ] 🇱🇹 **Lithuanian** (`lt`) — Lietuvių
- [ ] 🇸🇮 **Slovenian** (`sl`) — Slovenščina
- [ ] 🇱🇻 **Latvian** (`lv`) — Latviešu
- [ ] 🇪🇪 **Estonian** (`et`) — Eesti
- [ ] 🇪🇸 **Basque** (`eu`) — Euskara
- [ ] 🇪🇸 **Catalan** (`ca`) — Català
- [ ] 🏴󠁧󠁢󠁷󠁬󠁳󠁿 **Welsh** (`cy`) — Cymraeg
- [ ] 🇮🇪 **Irish** (`ga`) — Gaeilge
- [ ] 🇮🇸 **Icelandic** (`is`) — Íslenska
- [ ] 🇦🇱 **Albanian** (`sq`) — Shqip
- [ ] 🇲🇰 **Macedonian** (`mk`) — Македонски
- [ ] 🇦🇲 **Armenian** (`hy`) — Հայերեն
- [ ] 🇬🇪 **Georgian** (`ka`) — ქართული

</details>

---

## 🛠️ Step-by-Step Translation Guide

You don't need deep programming experience to help translate NoteKar!

### Step 1: Create the ARB Localization File

1. Open [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb).
2. Create a new file in `lib/l10n/` named `app_<language_code>.arb` (e.g., `app_pt.arb` for
   Portuguese).
3. Translate all values on the right-hand side while keeping key names unchanged:

```json
{
  "@@locale": "pt",
  "appTitle": "NoteKar",
  "settingsTitle": "Configurações",
  "historyTitle": "Histórico",
  "whatsNewTitle": "Novidades no NoteKar",
  "changelogTitle": "Registro de alterações",
  "displayCategory": "Exibição",
  "accentColorCategory": "Cor de destaque",
  "appIconsCategory": "Ícones do aplicativo",
  "captureCategory": "Captura",
  "momentsCategory": "Momentos",
  "backupExportCategory": "Backup e exportação",
  "privacySecurityCategory": "Privacidade e segurança",
  "accessibilityCategory": "Acessibilidade",
  "resetCategory": "Redefinir",
  "diagnosticsCategory": "Diagnósticos",
  "loadOlderMoments": "Carregar momentos anteriores",
  "noResultsFound": "Nenhum resultado encontrado",
  "clearSearch": "Limpar pesquisa",
  "cancel": "Cancelar",
  "save": "Salvar",
  "confirm": "Confirmar",
  "delete": "Excluir"
}
```

---

### Step 2: Add Dynamic Translations (`lib/utils/l10n_utils.dart`)

NoteKar provides dynamic string resolution for settings descriptions, badges, and feedback via [
`lib/utils/l10n_utils.dart`](lib/utils/l10n_utils.dart).

1. In `lib/utils/l10n_utils.dart`, create a
   `const Map<String, String> _<lang>Translations = { ... };` dictionary map with your language
   translations.
2. Add your language locale check in the `localized(BuildContext context)` extension:

```dart
if (l10n.localeName == 'pt') {
  final pt = _ptTranslations[normKey];
  if (pt != null) return pt;
}
```

---

### Step 3: Test and Submit

1. Run Flutter code generator and format:
   ```bash
   flutter gen-l10n
   dart format lib test
   ```
2. Run test verification:
   ```bash
   flutter test
   ```
3. Commit and push your changes:
   ```bash
   git checkout -b feature/l10n-<language_code>
   git add lib/l10n/ lib/utils/l10n_utils.dart
   git commit -m "l10n: add <LanguageName> translation support (<language_code>)"
   git push origin feature/l10n-<language_code>
   ```
4. Open a **Pull Request** on GitHub!

---

## 💖 Thank You!

Your contribution directly helps thousands of users across the globe experience private,
offline-first timestamp logging in their mother tongue.
