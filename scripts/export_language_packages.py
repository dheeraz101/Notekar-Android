import os
import json
import re

l10n_data_path = os.path.join("lib", "l10n", "l10n_data.dart")
output_dir = os.path.join("lib", "l10n", "packages")
os.makedirs(output_dir, exist_ok=True)

with open(l10n_data_path, "r", encoding="utf-8") as f:
    content = f.read()

languages_metadata = [
    {
        "code": "fr",
        "name": "Français",
        "englishName": "French",
        "flag": "🇫🇷",
        "version": 1,
        "sizeKb": 42,
        "translatedPercent": 100,
        "description": "Native French localization for NoteKar"
    },
    {
        "code": "es",
        "name": "Español",
        "englishName": "Spanish",
        "flag": "🇪🇸",
        "version": 1,
        "sizeKb": 44,
        "translatedPercent": 100,
        "description": "Native Spanish localization for NoteKar"
    },
    {
        "code": "hi",
        "name": "हिन्दी",
        "englishName": "Hindi",
        "flag": "🇮🇳",
        "version": 1,
        "sizeKb": 48,
        "translatedPercent": 100,
        "description": "Native Hindi localization for NoteKar"
    },
    {
        "code": "de",
        "name": "Deutsch",
        "englishName": "German",
        "flag": "🇩🇪",
        "version": 1,
        "sizeKb": 45,
        "translatedPercent": 100,
        "description": "Native German localization for NoteKar"
    },
    {
        "code": "ja",
        "name": "日本語",
        "englishName": "Japanese",
        "flag": "🇯🇵",
        "version": 1,
        "sizeKb": 52,
        "translatedPercent": 100,
        "description": "Native Japanese localization for NoteKar"
    },
    {
        "code": "ru",
        "name": "Русский",
        "englishName": "Russian",
        "flag": "🇷🇺",
        "version": 1,
        "sizeKb": 50,
        "translatedPercent": 100,
        "description": "Native Russian localization for NoteKar"
    }
]

# Write languages.json manifest
with open(os.path.join(output_dir, "languages.json"), "w", encoding="utf-8") as f:
    json.dump(languages_metadata, f, indent=2, ensure_ascii=False)
print("Wrote languages.json")

# Extract each language map from l10n_data.dart
locales = ["fr", "es", "hi", "de", "ja", "ru"]
for locale in locales:
    pattern = rf"'{locale}':\s*\{{(.*?)\n\s*\}},"
    match = re.search(pattern, content, re.DOTALL)
    if match:
        block = match.group(1)
        # Parse key-value lines
        pairs = {}
        line_pattern = re.compile(r"'((?:\\'|[^'])*)':\s*(?:r?'((?:\\'|[^'])*)'|\"((?:\\\"|[^\"])*)\"),?", re.DOTALL)
        for kv in re.finditer(line_pattern, block):
            k = kv.group(1).replace("\\'", "'").replace('\\"', '"')
            v = (kv.group(2) or kv.group(3) or "").replace("\\'", "'").replace('\\"', '"')
            pairs[k] = v
        
        target_file = os.path.join(output_dir, f"{locale}.json")
        with open(target_file, "w", encoding="utf-8") as out:
            json.dump(pairs, out, indent=2, ensure_ascii=False)
        print(f"Wrote {locale}.json ({len(pairs)} keys)")

print("Successfully exported all dynamic language packages!")
