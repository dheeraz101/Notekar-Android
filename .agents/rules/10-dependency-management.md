---
description: Mandatory standards for third-party dependency governance, licensing, and binary footprint
globs: pubspec.yaml, pubspec.lock, android/build.gradle.kts, android/app/build.gradle.kts
---

# 10 - Dependency Management Standard

## 1. Zero Unnecessary Dependencies
- **Strict Prohibition**: Never add third-party Flutter packages or Gradle dependencies without explicit user request and approval.
- Before considering an external library, evaluate if the capability can be achieved cleanly with:
  1. Built-in Dart / Flutter framework APIs (`dart:async`, `dart:convert`, `dart:math`).
  2. Native Android APIs via existing platform channels.
  3. Already installed packages in `pubspec.yaml` (e.g. `intl`, `crypto`, `isar`).

## 2. Dependency Audit Checklist
If a new dependency is approved by the user:
- [ ] **License Compatibility**: Must be MIT, Apache 2.0, or BSD. Strictly avoid GPL or copyleft licenses.
- [ ] **Zero Telemetry**: Must contain no analytics tracking, remote reporting, or proprietary cloud SDKs.
- [ ] **Binary Size Footprint**: Evaluate APK size impact. Reject heavy packages that bundle bloated C++ libraries if lightweight alternatives exist.
- [ ] **Maintenance Health**: Package must support current Flutter stable, Dart 3 null-safety, and Android API 35+.
- [ ] **Lockfile Pinning**: Commit `pubspec.lock` with deterministic package resolutions.

## 3. NDK & Native Library Pinning
- Do not specify arbitrary `ndkVersion` in `app/build.gradle.kts` that forces dynamic 1.2GB downloads in CI. Let AGP detect host-installed NDK when native compilation is needed.
