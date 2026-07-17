# NoteKar 4.0.3

Release date: June 17, 2026
Build: 12

## What's new

- Added backup validation before import so damaged JSON, invalid moments, oversized files, unsupported moment types, and unsafe note data are rejected before anything changes.
- Added a backup import preview that shows total moments, notes, export date, new moments, duplicates skipped, and settings to restore.
- Made backup import crash-safer by validating and persisting the merged data before updating the visible app state.
- Added dry-run import summaries for clearer recovery decisions before merging backups.
- Improved startup sequencing so first paint, App Lock, and non-critical startup checks are staged more smoothly.
- Added timeline profiling markers for startup load, deferred startup checks, backup validation, and backup persistence.
- Cached Settings search, note search, and calendar date lookups for smoother repeated use.
- Added focused tests for backup validation, corrupted files, duplicate detection, unknown moment types, and dry-run summaries.

## APKs

- `notekar-4.0.3-universal.apk` - works on most Android devices.
- `notekar-4.0.3-arm64-v8a.apk` - recommended for most modern phones.
- `notekar-4.0.3-armeabi-v7a.apk` - for older 32-bit phones.
- `notekar-4.0.3-x86_64.apk` - for x86_64 Android devices/emulators.

Generate fresh APKs and `sha256.txt` before publishing this release.
