import os
import re

snsp = "lib/dialogs/settings/search_notes_settings_page.dart"
with open(snsp, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'required bool compactHistory,', "required String historyDensity,", content)
# It might use it for `TimelineDaySection` or `TimelineSingleTile` or something
content = re.sub(r'compactHistory:', "compactRows: historyDensity == 'compact',", content)
content = re.sub(r'compactRows:\s*compactHistory', "compactRows: historyDensity == 'compact'", content)
# wait what if it passes it to another widget?
content = re.sub(r'compactHistory:\s*compactHistory', "compactHistory: historyDensity == 'compact'", content)
content = re.sub(r'compactHistory\s*\?', "historyDensity == 'compact' ?", content)

with open(snsp, 'w', encoding='utf-8') as f:
    f.write(content)

sd = "lib/dialogs/settings_dialog.dart"
with open(sd, 'r', encoding='utf-8') as f:
    sd_content = f.read()

sd_content = re.sub(r'compactHistory:.*?,', "historyDensity: historyDensity,", sd_content)

with open(sd, 'w', encoding='utf-8') as f:
    f.write(sd_content)

print("patched search notes settings")
