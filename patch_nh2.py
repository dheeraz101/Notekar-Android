import os

nh = "lib/screens/note_kar_home.dart"
with open(nh, 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find("onCompactHistory: (value) {")
if start_idx != -1:
    end_idx = content.find("},", start_idx) + 2
    content = content[:start_idx] + content[end_idx:]

with open(nh, 'w', encoding='utf-8') as f:
    f.write(content)

print("patched nh str bounds")
