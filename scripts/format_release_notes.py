#!/usr/bin/env python3
import os
import re
import sys

def format_release_notes(file_path: str) -> None:
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}", file=sys.stderr)
        return

    with open(file_path, "r", encoding="utf-8") as f:
        text = f.read()

    status = os.environ.get("VT_STATUS", "Undetected by 60+ engines")
    url = os.environ.get("VT_URL", "")
    date = os.environ.get("SCAN_DATE_STR", "")

    # 1. Remove placeholder or existing VirusTotal lines from the top Integrity section
    text = re.sub(r"(?mi)^[ \t]*[-*]?[ \t]*\**VirusTotal[^\r\n]*\r?\n?", "", text)

    # 2. Rename Security and Integrity heading to Integrity
    text = re.sub(r"(?m)^###? (?:Security and Integrity|Integrity and Security|Integrity and Verification)", "### Integrity", text)

    # 3. Construct clean Security section
    security_block = f"## Security\n\n🛡️ **VirusTotal Status**: `{status}`  \n🔗 [View Full Report]({url})  \n📅 Last scanned: {date}\n"

    # 4. If a standalone Security block already exists, update it; otherwise insert after Integrity or append
    sec_pattern = r"(?ms)^##+ Security\s*?\r?\n.*?(?=\r?\n---|(?:\r?\n##+ )|\Z)"
    if re.search(sec_pattern, text):
        text = re.sub(sec_pattern, security_block, text)
    else:
        integ_match = re.search(r"(?ms)(^### Integrity\b.*?(?=\r?\n---|(?:\r?\n##+ )|\Z))", text)
        if integ_match:
            integ_end = integ_match.end()
            text = text[:integ_end].rstrip() + "\n\n---\n\n" + security_block + text[integ_end:].lstrip()
        else:
            text = text.rstrip() + "\n\n---\n\n" + security_block

    # Clean up duplicate horizontal rules
    text = re.sub(r"(\r?\n---[ \t]*){2,}", "\n---", text)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(text.rstrip() + "\n")

    print(f"Successfully formatted release notes: {file_path}")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "/tmp/release_notes.md"
    format_release_notes(target)
