# Security Policy: NoteKar Android

NoteKar Android prioritizes app security and user privacy. Because NoteKar Android is an **offline-first application using local Isar and SharedPreferences storage**, all user timestamps and notes remain locally on the user's device.

---

## Supported Versions

Security updates and patches are provided for the following active channels:

| Version Channel | Supported |
| :--- | :--- |
| Latest Active Release (v7.x) | :white_check_mark: |
| Active Beta Channel | :white_check_mark: |
| Older Legacy Releases | :x: |

---

## 🛡️ Air-Gap & Cryptographic Verification Protocol

For third-party security auditors, privacy advocates, and open-source contributors, NoteKar provides verifiable guarantees:

### 1. Zero Network Telemetry (100% Air-Gapped)
- NoteKar does not declare the `android.permission.INTERNET` permission in its production AndroidManifest.
- **Audit Verification Command**:
  ```bash
  grep -i "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml
  # Returns 0 results
  ```
- Zero third-party analytics SDKs, zero crash reporters, zero remote tracking pixels.

### 2. Sovereign Vault Encryption
- Encrypted `.notekar-vault` exports utilize **PBKDF2-HMAC-SHA256** with $\ge 100,000$ iterations (200,000 iterations for new vaults) and **AES-256-GCM** authenticated ciphertext.
- All restored attachments undergo strict sandbox boundary checks preventing directory traversal (`../`) injection.

---

## Reporting a Vulnerability

If you discover a security vulnerability or privacy leak in NoteKar Android, please **do not open a public issue on GitHub**. Report it privately to the maintainer:

- 📧 **Email:** [yabp.support@gmail.com](mailto:yabp.support@gmail.com)

### Please Include:
- Description of the vulnerability and potential security impact.
- Clear steps to reproduce or minimal proof-of-concept.
- Android OS version, build tag, and device model.
- ⚠️ **Redaction Notice:** Please ensure you **do not** include personal notes, private timestamps, tokens, credentials, or sensitive device logs in your report.

The maintainer will review reports on a best-effort basis and prioritize actionable patches in subsequent builds.
