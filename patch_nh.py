import os
import re

nh = "lib/screens/note_kar_home.dart"
with open(nh, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'onCompactHistory:\s*\(value\)\s*\{\s*setState\(\(\)\s*\{\s*_compactHistory\s*=\s*value;\s*_historyDensity\s*=\s*value \? \'compact\' : \'comfortable\';\s*\}\);\s*_saveSetting\(\'m-compact-history\',\s*value\);\s*\},', '', content)
content = re.sub(r'_historyDensity = savedCompact \? \'compact\' : \'comfortable\';', '', content)

with open(nh, 'w', encoding='utf-8') as f:
    f.write(content)

test = "test/life_ledger_timeline_test.dart"
if os.path.exists(test):
    with open(test, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'compactHistory:.*?,', "historyDensity: 'comfortable',", content)
    with open(test, 'w', encoding='utf-8') as f:
        f.write(content)

print("patched nh and test")
