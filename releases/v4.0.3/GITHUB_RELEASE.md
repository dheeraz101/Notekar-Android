# NoteKar 4.0.3

NoteKar 4.0.3 is a backup-safety and performance-hardening release for the Android Flutter app.

## Highlights

- Backup validation now runs before import, rejecting damaged JSON, invalid moment rows, oversized files, unsupported moment types, and unsafe note data before current data is touched.
- Import now shows a preview with backup moments, notes, exported date, new moments, duplicates skipped, and settings to restore.
- Backup import is more crash-safe: NoteKar validates and persists the merged data before updating the visible app state.
- Startup work is staged more smoothly so first paint, App Lock, and non-critical checks do not compete as heavily.
- Timeline markers were added for startup and backup import profiling in DevTools.
- Settings search, note search, and calendar date lookups now cache their working indexes for smoother repeated use.
- New tests cover backup validation, corrupted files, duplicate detection, unknown moment types, and dry-run import summaries.

## Downloads

- Universal: `notekar-4.0.3-universal.apk`
- ARM64: `notekar-4.0.3-arm64-v8a.apk`
- ARMv7: `notekar-4.0.3-armeabi-v7a.apk`
- x86_64: `notekar-4.0.3-x86_64.apk`

## Verification

Run the release build script to generate fresh APKs and `sha256.txt`, then paste the checksums here before publishing.

## SHA256

```text
7c5f40cc1502ef710e7620a7125e7834763a4c852359085c8f44a9c2e1ccd520  notekar-4.0.3-arm64-v8a.apk
fa02d0bddae6a2929b69a87029cb10afc9d56db6b7754154247b07e69d9b9895  notekar-4.0.3-armeabi-v7a.apk
5613e3524da01876cf00abd376efa7a4ddb11ded57976da015a82934692309cb  notekar-4.0.3-universal.apk
bc00a9c7d52383977ae936c156b283edc473835323f84afa8bee8219bd4885fa  notekar-4.0.3-x86_64.apk
```
