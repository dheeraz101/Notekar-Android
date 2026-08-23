import os
import re
import json

def parse_dart_map(map_body):
    """Accurately parse a Dart Map<String, String> body handling escaped quotes."""
    entries = {}
    i = 0
    n = len(map_body)
    while i < n:
        # Skip whitespace and commas
        while i < n and map_body[i] in ' \t\r\n,':
            i += 1
        if i >= n:
            break
        # Read key string
        quote_char = map_body[i]
        if quote_char not in ("'", '"'):
            if map_body[i:i+2] == '//':
                while i < n and map_body[i] != '\n':
                    i += 1
                continue
            i += 1
            continue
        i += 1
        key_chars = []
        while i < n:
            c = map_body[i]
            if c == '\\':
                if i + 1 < n:
                    next_c = map_body[i+1]
                    if next_c in ("'", '"', '\\', 'n', 'r', 't'):
                        if next_c == 'n': key_chars.append('\n')
                        elif next_c == 'r': key_chars.append('\r')
                        elif next_c == 't': key_chars.append('\t')
                        else: key_chars.append(next_c)
                        i += 2
                        continue
                    else:
                        key_chars.append(c)
                i += 1
                continue
            elif c == quote_char:
                i += 1
                break
            else:
                key_chars.append(c)
                i += 1
        key = "".join(key_chars)

        # Look for colon ':'
        while i < n and map_body[i] in ' \t\r\n':
            i += 1
        if i < n and map_body[i] == ':':
            i += 1
        else:
            continue

        # Look for value start
        while i < n and map_body[i] in ' \t\r\n':
            i += 1
        if i >= n:
            break
        val_quote = map_body[i]
        if val_quote not in ("'", '"'):
            continue
        i += 1
        val_chars = []
        while i < n:
            c = map_body[i]
            if c == '\\':
                if i + 1 < n:
                    next_c = map_body[i+1]
                    if next_c in ("'", '"', '\\', 'n', 'r', 't'):
                        if next_c == 'n': val_chars.append('\n')
                        elif next_c == 'r': val_chars.append('\r')
                        elif next_c == 't': val_chars.append('\t')
                        else: val_chars.append(next_c)
                        i += 2
                        continue
                    else:
                        val_chars.append(c)
                i += 1
                continue
            elif c == val_quote:
                i += 1
                break
            else:
                val_chars.append(c)
                i += 1
        val = "".join(val_chars)
        entries[key.strip().lower()] = val
    return entries

def parse_switch_cases(content):
    """Parse switch cases for es, hi, fr, de, ja, ru."""
    # Find each case 'some key' => switch (l10n.localeName) { ... }
    pattern = r"['\"]([^'\"]+)['\"]\s*=>\s*switch\s*\([^\)]+\)\s*\{([^}]+)\}"
    matches = re.findall(pattern, content)
    cases = {}
    for key, block in matches:
        norm_key = key.strip().lower()
        cases[norm_key] = {}
        for lang in ['fr', 'es', 'hi', 'de', 'ja', 'ru']:
            # match 'lang' => 'val'
            m = re.search(rf"'{lang}'\s*=>\s*(?:'((?:[^'\\]|\\.)*)'|\"((?:[^\"\\]|\\.)*)\")", block)
            if m:
                raw_val = m.group(1) if m.group(1) is not None else m.group(2)
                # Unescape Dart string
                val = raw_val.replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n').replace('\\$', '$')
                cases[norm_key][lang] = val
    return cases

def main():
    root = r"c:\Users\dheer\OneDrive\Documents\dv\Android Projects\Project YABP DigitalSuraksha\Notekar - Flutter"
    source_file = r"C:\Users\dheer\.gemini\antigravity\brain\576a121a-3a06-4267-8ab6-4df12b98714c\scratch\original_l10n_utils.dart"
    l10n_dir = os.path.join(root, "lib", "l10n")

    with open(source_file, "r", encoding="utf-8") as f:
        content = f.read()

    languages = ['en', 'fr', 'es', 'hi', 'de', 'ja', 'ru']
    translations = {lang: {} for lang in languages}

    # 1. Parse Maps
    for lang in ['fr', 'de', 'ja', 'ru']:
        map_match = re.search(rf"const\s+Map<String,\s*String>\s+_{lang}Translations\s*=\s*\{{(.*?)\}};\s*(?:const\s+Map|\Z)", content, re.DOTALL)
        if map_match:
            parsed = parse_dart_map(map_match.group(1))
            translations[lang].update(parsed)
            for k in parsed:
                if k not in translations['en']:
                    translations['en'][k] = k
            print(f"Loaded {len(parsed)} keys from _{lang}Translations")

    # 2. Parse Switch Cases
    switch_cases = parse_switch_cases(content)
    print(f"Loaded {len(switch_cases)} switch cases")
    for norm_key, lang_vals in switch_cases.items():
        if norm_key not in translations['en']:
            translations['en'][norm_key] = norm_key
        for lang, val in lang_vals.items():
            translations[lang][norm_key] = val

    all_keys = sorted(list(translations['en'].keys()))
    print(f"Total unified keys: {len(all_keys)}")
    for lang in languages:
        print(f"Language '{lang}': {len(translations[lang])} translations")

    # Write out ARB files
    for lang in languages:
        arb_path = os.path.join(l10n_dir, f"app_{lang}.arb")
        arb_dict = {"@@locale": lang}
        for k in all_keys:
            val = translations[lang].get(k, translations['en'].get(k, k))
            arb_dict[k] = val

        with open(arb_path, "w", encoding="utf-8") as f:
            json.dump(arb_dict, f, ensure_ascii=False, indent=2)
        print(f"Wrote {arb_path} ({len(arb_dict) - 1} keys)")

    # Generate lib/l10n/l10n_data.dart
    l10n_data_path = os.path.join(l10n_dir, "l10n_data.dart")
    with open(l10n_data_path, "w", encoding="utf-8") as f:
        f.write("// Generated localization dictionary compiled from lib/l10n/*.arb files.\n")
        f.write("// DO NOT EDIT DIRECTLY. Edit the respective .arb files in lib/l10n/.\n\n")
        f.write("const Map<String, Map<String, String>> kL10nTranslations = {\n")
        for lang in ['fr', 'es', 'hi', 'de', 'ja', 'ru']:
            f.write(f"  '{lang}': {{\n")
            for k in all_keys:
                if k in translations[lang]:
                    val = translations[lang][k].replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("$", "\\$")
                    escaped_k = k.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("$", "\\$")
                    f.write(f"    '{escaped_k}': '{val}',\n")
            f.write("  },\n")
        f.write("};\n")
    print(f"Wrote {l10n_data_path}")

    # Generate slim lib/utils/l10n_utils.dart (~95 lines)
    slim_l10n_utils = """import 'package:flutter/material.dart';
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

    final translation = kL10nTranslations[l10n.localeName]?[normKey];
    return translation ?? this;
  }
}
"""
    l10n_utils_path = os.path.join(root, "lib", "utils", "l10n_utils.dart")
    with open(l10n_utils_path, "w", encoding="utf-8") as f:
        f.write(slim_l10n_utils)
    print(f"Wrote slim {l10n_utils_path}")

if __name__ == "__main__":
    main()
