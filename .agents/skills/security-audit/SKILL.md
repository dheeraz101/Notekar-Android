---
name: security-audit
description: Audit NoteKar for zero-telemetry air-gap compliance, cryptographic vault strength, and secure Android IPC flags.
---

# Security & Air-Gap Audit

Execute the security and air-gap audit workflow for NoteKar:

1. Follow all steps in [.agents/workflows/07-security-privacy-audit.md](file:///.agents/workflows/07-security-privacy-audit.md).
2. Scan codebase for unauthorized HTTP/HTTPS/WebSocket calls; confirm zero third-party telemetry SDKs.
3. Verify AndroidManifest.xml contains no `android.permission.INTERNET`.
4. Audit cryptographic vault: PBKDF2 (>= 100k iterations) + AES-256-GCM.
5. Verify sensitive keys excluded from backup in `data_extraction_rules.xml`.
6. Audit Android BroadcastReceiver export flags (`RECEIVER_EXPORTED` / `RECEIVER_NOT_EXPORTED`).
7. Run `flutter test test/vault_encryption_service_test.dart`.
