import os
import re
import glob

files = glob.glob('lib/**/*.dart', recursive=True)
for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # If it has Cupertino string but no import, add the import
    if "Cupertino" in content and "import 'package:flutter/cupertino.dart';" not in content:
        content = re.sub(r"(import .*?;)", r"import 'package:flutter/cupertino.dart';\n\1", content, count=1)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)

# Also fix the Icons missing in activity_tag.dart
at = 'lib/models/activity_tag.dart'
if os.path.exists(at):
    with open(at, 'r', encoding='utf-8') as f:
        content = f.read()
    if "import 'package:flutter/material.dart';" not in content:
        content = "import 'package:flutter/material.dart';\n" + content
        with open(at, 'w', encoding='utf-8') as f:
            f.write(content)

print("Imports restored!")
