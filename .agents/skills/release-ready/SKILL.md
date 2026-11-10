---
name: release-ready
description: Verify release-readiness, version synchronization, multi-ABI signed builds, and SHA-256 release checksums for NoteKar.
---

# Release-Readiness Verification

Execute the release-readiness verification workflow for NoteKar:

1. Follow all steps in [.agents/workflows/08-release-readiness-verification.md](file:///.agents/workflows/08-release-readiness-verification.md).
2. Verify version synchronization across `pubspec.yaml`, `local.properties`, `app_utils.dart`, and `CHANGELOG.md` (or run `.\scripts\update-version.ps1`).
3. Run full verification gate: `.\scripts\verify.ps1`.
4. Compile signed multi-ABI release APKs: `.\scripts\build-release-apks.ps1`.
5. Compute SHA-256 checksums on generated APKs in `releases/`.
6. Inspect Proguard / R8 build logs for missing classes or obfuscation anomalies.
