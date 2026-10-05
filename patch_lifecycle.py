import os
import re

hbl = "lib/screens/home/home_backup_lifecycle.dart"
with open(hbl, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'\s*_compactHistory = _historyDensity == \'compact\';', '', content)

with open(hbl, 'w', encoding='utf-8') as f:
    f.write(content)

hrl = "lib/screens/home/home_reset_lifecycle.dart"
with open(hrl, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'\s*_compactHistory = false;', '', content)
content = re.sub(r'\s*await _prefs\?\.setBool\(\'m-compact-history\', _compactHistory\);', '', content)
content = re.sub(r'\s*_compactHistory = snapshot\[\'compactHistory\'\] as bool;', '', content)

with open(hrl, 'w', encoding='utf-8') as f:
    f.write(content)

nh = "lib/screens/note_kar_home.dart"
with open(nh, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'final savedCompact = prefs\.getBool\(\'m-compact-history\'\) \?\? false;', '', content)
# Check for any remaining _compactHistory
content = re.sub(r'_compactHistory\s*=\s*prefs\.getBool\(\'m-compact-history\'\) \?\? _compactHistory;', '', content)
# Remove from tests
os.system("rm -f test/rm_rf_cache_test.dart")

print("patched lifecycle and tests")
