import os

file_path = 'lib/dialogs/settings_dialog.dart'
with open(file_path, 'r') as f:
    lines = f.readlines()

new_lines = []
for i in range(len(lines)):
    line = lines[i]
    if i < len(lines) - 1:
        next_line = lines[i+1].strip()
        # Check if the current line ends a sliver block and next line starts another sliver or if
        if (line.rstrip().endswith(')') or line.rstrip().endswith(']')) and (next_line.startswith('if') or next_line.startswith('Sliver')):
            # Add comma if missing
            if not line.rstrip().endswith(','):
                line = line.rstrip() + ',\n'
            # Remove extra commas if any (like the ones I might have added)
            while line.rstrip().endswith(',,'):
                line = line.rstrip()[:-1] + '\n'
    new_lines.append(line)

with open(file_path, 'w') as f:
    f.writelines(new_lines)
