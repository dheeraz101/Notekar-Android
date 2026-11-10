---
name: app-audit
description: Run an exhaustive architecture, lint, test health, native Android, and security audit of the NoteKar codebase.
---

# Complete Application Audit

Execute the complete application audit workflow for NoteKar:

1. Follow all steps in [.agents/workflows/01-complete-application-audit.md](file:///.agents/workflows/01-complete-application-audit.md).
2. Run `flutter pub outdated`.
3. Run `flutter analyze --fatal-infos --fatal-warnings`.
4. Run `dart format --output=none --set-exit-if-changed lib/ test/`.
5. Run `flutter test`.
6. Audit Android permissions in `android/app/src/main/AndroidManifest.xml`.
7. Audit zero-telemetry and cryptographic vault standards.
8. Output a comprehensive audit report.
