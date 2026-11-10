---
description: Mandatory standards for defensive error handling, safe fallbacks, ByteData buffer slicing, and database migrations
globs: lib/**/*.dart, test/**/*.dart, android/app/**/*.kt
---

# 06 - Error Handling & Defensive Resilience Standard

## 1. ByteData Buffer Slicing Invariant
When converting `ByteData` from asset bundles (`rootBundle.load(...)`) or network buffers into `Uint8List`:
- **Always Pass Offset and Length**:
  ```dart
  final uint8List = byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
  ```
- **Never Call `asUint8List()` Without Arguments**: Asset bundles share backing buffers. Omitting arguments slices from byte 0, corrupting file headers (JPEG/PNG/WebP).

## 2. Database Schema Migration Safety
- Never assume a fresh database. Users upgrade through versions; an existing database file will be present on disk.
- Any modification to Isar or Hive models must include an idempotent migration routine in `initialize()`.
- Never delete old database boxes during migration until successful verification of imported data.
- Guard migration routines with persistent version flags (e.g. `legacy_migrated_v2`).

## 3. Platform Channel Resilience
- All `MethodChannel` invocations between Flutter and Android Kotlin must be wrapped in `try-catch` blocks handling `PlatformException` and `MissingPluginException`.
- Provide sensible UI fallbacks when platform services (e.g. step counter, camera, audio recorder) are unavailable on specific Android hardware.

## 4. Unawaited Futures & Null Safety
- Never leave asynchronous calls unawaited in event handlers without explicit intention (`unawaited()`).
- Always handle `null` safely using Dart null-aware operators (`?.`, `??`).
- When parsing JSON from external or storage sources, use type guards and fallback defaults for every field.
