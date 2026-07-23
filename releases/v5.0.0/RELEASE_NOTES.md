## NoteKar v5.0.0 (Stable Release)

Signed release - built automatically from the branch.

### 🚀 What's New

- **Windows-Style Updates Classification System**: Automatically classifies update packages into Feature, Security, or Beta updates with matching colors, channel badges, and layout designs.
- **Native Markdown Text Renderer (`MarkdownText`)**: Formats headers, bullet lists, bold text, horizontal rules, custom code tags, and hyperlinks inside release notes natively using the app color palette.
- **Double Action Buttons**: The update checker card now supports downloading/installing packages and re-checking update status simultaneously.
- **Background reminders & UI refinements**: Added premium iOS Cupertino Activity Indicators, a 3-second transparent overlay when toggling release tracks, and focus listeners for composer icons.
- **Track Switch Downgrades explanation guide** inside the Help FAQ section.
- **Polished track select numbered list** on the Build Choose subpage with baseline-aligned number columns.
- **Build automation**: Automated PowerShell version calculations for Major (`-stable`), Minor (`-security`), and Patch (`-beta`) increments across core config files.

### 🛠️ Bug Fixes

- **Beta APK 404 Download Failures**: Configured the updater client to track release tagNames (e.g. `v5.0.0-beta`) when resolving file paths, ensuring download requests never throw 404 errors.
- **VirusTotal size limits**: Updated the compilation pipeline to fetch custom large-file upload endpoints, resolving HTTP `413 Request Entity Too Large` failures on universal APK uploads (60MB+).
- **Perl delimeter conflicts**: Fixed regex warnings on release notes formatters by switching regex delimiters.
- **Update Classification heuristic checks**: Ensured markdown headers in release descriptions (like `### Security`) do not misclassify Beta pre-releases as Security updates.
- **Version Layout Adjustments**: Standardized up-to-date labels to display the version name alongside build codes.

### Security and Integrity
NoteKar binaries undergo automated compilation and scanning.
- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder
