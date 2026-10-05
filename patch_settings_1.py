import os
import re

sd = "lib/dialogs/settings_dialog.dart"
with open(sd, 'r', encoding='utf-8') as f:
    sd_content = f.read()

sd_content = re.sub(r'required this\.compactHistory,', '', sd_content)
sd_content = re.sub(r'required this\.onCompactHistory,', '', sd_content)
sd_content = re.sub(r'final bool compactHistory;', '', sd_content)
sd_content = re.sub(r'final ValueChanged<bool> onCompactHistory;', '', sd_content)
sd_content = re.sub(r'late bool compactHistory;', '', sd_content)
sd_content = re.sub(r'compactHistory\s*=\s*widget\.compactHistory;', '', sd_content)
sd_content = re.sub(r'compactHistory:\s*compactHistory,', '', sd_content)
sd_content = re.sub(r'onCompactHistoryChanged:\s*\(value\)\s*\{\s*setState\(\(\)\s*=>\s*compactHistory\s*=\s*value\);\s*widget\.onCompactHistory\(value\);\s*\},', '', sd_content)
sd_content = re.sub(r'onCompactHistory:\s*\(value\)\s*\{\s*setState\(\(\)\s*=>\s*compactHistory\s*=\s*value\);\s*widget\.onCompactHistory\(value\);\s*\},', '', sd_content)

with open(sd, 'w', encoding='utf-8') as f:
    f.write(sd_content)

hs = "lib/dialogs/settings/history_settings_page.dart"
if os.path.exists(hs):
    with open(hs, 'r', encoding='utf-8') as f:
        hs_content = f.read()
    
    hs_content = re.sub(r'required this\.compactHistory,', '', hs_content)
    hs_content = re.sub(r'required this\.onCompactHistoryChanged,', '', hs_content)
    hs_content = re.sub(r'final bool compactHistory;', '', hs_content)
    hs_content = re.sub(r'final ValueChanged<bool> onCompactHistoryChanged;', '', hs_content)
    
    # Remove the compact history toggle from UI
    hs_content = re.sub(r'SettingsRow\(\s*label:\s*\'Compact History\',[^;]+;[^;]+;[^;]+;[^;]+\),', '', hs_content, flags=re.DOTALL)
    hs_content = re.sub(r'SettingsRow\(\s*label:\s*\'Compact History\'.*?onChanged:\s*onCompactHistoryChanged,\s*\),?', '', hs_content, flags=re.DOTALL)
    
    with open(hs, 'w', encoding='utf-8') as f:
        f.write(hs_content)

print("settings_dialog updated")
