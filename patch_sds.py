import os
import re

sds = "lib/dialogs/settings/settings_dialog_search.dart"
with open(sds, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'this\.compactHistory = false,', '', content)
content = re.sub(r'this\.onCompactHistory,', '', content)
content = re.sub(r'final bool compactHistory;', '', content)
content = re.sub(r'final ValueChanged<bool>\? onCompactHistory;', '', content)
content = re.sub(r'late bool compactHistory;', '', content)
content = re.sub(r'compactHistory = widget\.compactHistory;', '', content)

content = re.sub(r'value && compactHistory', "value && historyDensity == 'compact'", content)
content = re.sub(r'compactHistory = false;', '', content)
content = re.sub(r'widget\.onCompactHistory\(false\);', '', content)
content = re.sub(r'widget\.onCompactHistory\?\.\w+\(.*?\);?', '', content)

with open(sds, 'w', encoding='utf-8') as f:
    f.write(content)

print("settings_dialog_search updated")
