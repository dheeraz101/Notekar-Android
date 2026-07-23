# NoteKar 3.0.0

NoteKar 3.0.0 is a major native Android polish release focused on clearer Settings, safer reset flows, stronger offline behavior, cleaner History, and a more privacy-forward app experience.

## What's New

- Updated the app to `3.0.0+6`.
- Reshuffled Settings into clearer categories: Display, Capture, Moments, Backup & Export, Updates & Notices, Privacy & Security, Accessibility, and Reset.
- Added a dedicated Reset page with Reset Settings Only, Reset All Data, Factory Reset, backup-aware confirmation copy, and undo for Reset Settings Only.
- Added a full-screen Factory Reset flow with progress, completion state, and a Start button before the welcome setup appears.
- Added a Privacy & Security page with local-storage details, limited network-use notes, no analytics/telemetry disclosure, Android backup behavior, and planned encryption/Drive backup guidance.
- Improved Settings navigation so nested pages return naturally to their previous section.
- Improved offline-first startup by delaying remote notice checks until the app has loaded and connectivity is known.
- Refined History with true compact rows, smoother delete removal, cleaner swipe-delete visuals, scroll-to-top, and Single moments in duration selection.
- Changed backup import to merge imported moments with current local history instead of replacing device data.
- Added Note-Focused Hold so long press can require context before saving a note moment.
- Reduced noisy setting-change notification pills while keeping useful feedback for updates, exports, connectivity, and errors.
- Fixed the welcome theme picker, startup mode onboarding, duplicate clock controls, diagnostics copy, and Settings row icon alignment.

## APK Files

- `notekar-3.0.0-universal.apk` works on all supported Android ABIs.
- `notekar-3.0.0-arm64-v8a.apk` is recommended for most modern Android phones.
- `notekar-3.0.0-armeabi-v7a.apk` is for older 32-bit ARM devices.
- `notekar-3.0.0-x86_64.apk` is for x86_64 devices and emulators.

SHA-256 checksums are available in `SHA256SUMS.txt`.

## GitHub Release Note

NoteKar 3.0.0 is a major Android polish release with a calmer, clearer Settings experience, safer reset flows, stronger offline behavior, improved History, and clearer privacy controls.

Highlights:

- Redesigned Settings structure with dedicated Display, Capture, Moments, Backup & Export, Updates & Notices, Privacy & Security, Accessibility, and Reset sections.
- Full-screen Factory Reset experience with progress and a Start button before returning to the welcome setup.
- Backup-aware reset confirmations, Reset Settings undo, and backup import that merges instead of replacing local history.
- Privacy & Security page with local storage, limited network-use, no analytics/telemetry disclosure, Android backup behavior, and planned encryption/Drive backup guidance.
- Cleaner History with compact rows, smoother delete behavior, scroll-to-top, and Single moments in duration comparisons.
- Note-Focused Hold for users who want long press to save only when context is added.
- Less noisy setting-change feedback while keeping meaningful system, update, export, and error feedback.

Recommended file: `notekar-3.0.0-universal.apk`.
