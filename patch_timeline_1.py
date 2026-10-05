import os
import re

def replace_in_file(path, old, new):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# note_kar_home.dart
nh = "lib/screens/note_kar_home.dart"
with open(nh, 'r', encoding='utf-8') as f:
    nh_content = f.read()

nh_content = re.sub(r'bool _compactHistory\s*=\s*(false|true);', '', nh_content)
nh_content = re.sub(r'final savedCompact\s*=\s*prefs\.getBool\(\'m-compact-history\'\)\s*\?\?\s*false;\n', '', nh_content)
nh_content = re.sub(r'_compactHistory\s*=\s*savedCompact;', '', nh_content)
nh_content = re.sub(r'_compactHistory\s*=\s*prefs\.getBool\(\'m-compact-history\'\)\s*\?\?\s*_compactHistory;', '', nh_content)

nh_content = re.sub(r'compactHistory:\s*_compactHistory,', '', nh_content)
nh_content = re.sub(r'onCompactHistory:\s*\(value\)\s*\{\s*setState\(\(\)\s*\{\s*_compactHistory\s*=\s*value;\s*_historyDensity\s*=\s*value\s*\?\s*\'compact\'\s*:\s*\'comfortable\';\s*\}\);\s*_saveSetting\(\'m-compact-history\',\s*value\);\s*\},', '', nh_content)

nh_content = re.sub(r'compactRows:\s*_compactHistory,', 'compactRows: _historyDensity == \'compact\',', nh_content)
nh_content = re.sub(r'_compactHistory\s*=\s*value\s*!=\s*\'comfortable\';', '', nh_content)
nh_content = re.sub(r'_prefs\?\.setBool\(\'m-compact-history\',\s*value\s*!=\s*\'comfortable\'\);', '', nh_content)
nh_content = re.sub(r'onCompactHistory:\s*\(value\)\s*\{\s*setState\(\(\)\s*=>\s*_compactHistory\s*=\s*value\);\s*_prefs\?\.setBool\(\'m-compact-history\',\s*value\);\s*\},', '', nh_content)

with open(nh, 'w', encoding='utf-8') as f:
    f.write(nh_content)

print("note_kar_home updated")
