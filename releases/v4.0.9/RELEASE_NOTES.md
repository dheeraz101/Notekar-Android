## NoteKar v4.0.9 (Beta)

Signed release - built automatically from the branch.

### 🚀 What's New

- **Custom Markdown Text Renderer (`MarkdownText`)**: Implemented a native, lightweight Markdown formatter widget in Settings. This provides elegant rendering of headers, bullet lists, inline code blocks, bold text, and clickable hyperlinks in the "What's New" release notes.
- **Double Action Buttons**: The update card now provides simultaneous access to `"Install Now"` (when verified) and `"Check for updates"`.
- **Track Switching FAQ Guide**: Added an inline explanation inside Help & Guides answering why Stable updates don't show up immediately when downgrading from a higher Beta version.
- **Polished Track Selectors**: Numbered guidelines inside the Build Choose page now use clean baseline-aligned columns to prevent text wrapping under numbers.

### 🛠️ Bug Fixes

- **Beta APK 404 Download Failures**: Configured the updater client to track release tagNames (e.g. `v4.0.9-beta`) when resolving file paths, ensuring download requests never throw 404 errors.
- **VirusTotal size limits**: Updated the compilation pipeline to fetch custom large-file upload endpoints, resolving HTTP `413 Request Entity Too Large` failures on universal APK uploads (60MB+).
- **Perl delimeter conflicts**: Fixed regex warnings on release notes formatters by switching regex delimiters.
- **Update Classification heuristic checks**: Ensured markdown headers in release descriptions (like `### Security`) do not misclassify Beta pre-releases as Security updates.
- **Version Layout Adjustments**: Standardized up-to-date labels to display the version name alongside build codes.

### Security and Integrity
NoteKar binaries undergo automated compilation and scanning.
- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder
