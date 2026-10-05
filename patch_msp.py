import os
import re

msp = "lib/dialogs/settings/moments_settings_page.dart"
with open(msp, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'this\.compactHistory = false,', "this.historyDensity = 'comfortable',", content)
content = re.sub(r'final bool compactHistory;', 'final String historyDensity;', content)
content = re.sub(r'this\.onCompactHistoryChanged,', '', content)
content = re.sub(r'final ValueChanged<bool>\? onCompactHistoryChanged;', '', content)
content = re.sub(r'value && compactHistory', "value && historyDensity == 'compact'", content)
content = re.sub(r'onCompactHistoryChanged\?\.call\(false\);', '', content)

with open(msp, 'w', encoding='utf-8') as f:
    f.write(content)

print("moments_settings_page updated")
