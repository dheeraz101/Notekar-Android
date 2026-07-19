import sys

with open('lib/dialogs/settings_dialog.dart', 'r') as f:
    lines = f.readlines()

for i in range(len(lines) - 1):
    line = lines[i].rstrip()
    next_line = lines[i+1].strip()
    if (line.endswith(')') or line.endswith(']')) and not line.endswith(','):
        if not line.strip().startswith('if'):
            if next_line.startswith('if') or next_line.startswith('Sliver'):
                print(f'Line {i+1}: {line}')
