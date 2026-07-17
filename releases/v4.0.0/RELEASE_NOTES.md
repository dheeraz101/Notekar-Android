# NoteKar 4.0.0

NoteKar 4.0.0 is the final release package for the latest Android polish pass, focused on a cleaner Settings structure, real launcher icon choices, stronger App Lock behavior, and tighter privacy defaults.

## What's New

- Updated the app to `4.0.0+9`.
- Reduced Settings to six clearer top-level sections: Personalization, Logging, Privacy & Security, Data & Backup, Updates, and Advanced.
- Added real Android launcher icon switching with Default, Black, Blue, Gold, Green, Orange, and Red icons.
- Moved App Lock under Privacy & Security with timing that starts only after NoteKar is closed or sent to the background.
- Added empty-note validation, circular icon previews, full-note viewing from History, and smoother History scroll-to-top behavior.
- Moved Android Backup, Data Health, Encrypted Backup, and Google Drive Backup into the second-level Backup Status page.
- Tightened privacy/security behavior by avoiding clipboard fallback for failed exports and requiring HTTPS for remote notice links.

## APK Files

- `notekar-4.0.0-universal.apk` works on all supported Android ABIs.
- `notekar-4.0.0-arm64-v8a.apk` is recommended for most modern Android phones.
- `notekar-4.0.0-armeabi-v7a.apk` is for older 32-bit ARM devices.
- `notekar-4.0.0-x86_64.apk` is for x86_64 devices and emulators.

SHA-256 checksums are available in `sha256.txt`.

## GitHub Release Note

NoteKar 4.0.0 is the final Android release package for the latest polish wave.

Highlights:

- Settings is now calmer and easier to scan with six top-level sections and fewer duplicate pages.
- App Icons now changes the real Android launcher icon, with live circular previews in Settings.
- App Lock lives under Privacy & Security and locks only after the app is closed or backgrounded for the selected time.
- Backup status information now lives in its own second-level page so Backup & Export stays focused on actions.
- Note capture, History note viewing, and History scroll-to-top behavior are more polished for daily use.
- Failed exports no longer copy private backup/export content into the clipboard.
- Remote notice links now require HTTPS.

Recommended file: `notekar-4.0.0-universal.apk`.
