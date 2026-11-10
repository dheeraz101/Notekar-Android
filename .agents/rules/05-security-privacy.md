---
description: Mandatory standards for 100% offline-first architecture, zero telemetry, and sovereign cryptographic vaults
globs: lib/services/**/*.dart, lib/models/**/*.dart, android/app/**/*.kt, **/*.dart
---

# 05 - Security & Privacy Standard

## 1. Zero Telemetry & Air-Gapped Privacy
- **100% Offline-First**: NoteKar operates strictly locally on the user's device.
- **Forbidden Network Calls**:
  - Never add network analytics, tracking SDKs (Google Analytics, Firebase, Mixpanel), or advertising pixels.
  - Never send user moments, notes, tags, or timestamps over the network.
  - HTTP requests are restricted strictly to user-initiated explicit actions (such as checking for app update releases on GitHub if opted-in).

## 2. Sovereign Vault Encryption Standard
- All encrypted backup exports (`.notekar-vault`) must use authenticated cryptography:
  - **Key Derivation**: PBKDF2 with HMAC-SHA256, minimum **100,000 iterations**, and a **16-byte cryptographically secure random salt**.
  - **Cipher**: **AES-256-GCM** with a **12-byte initialization vector (IV)** and **128-bit authentication tag**.
  - Never use ECB mode, unauthenticated CBC, or hardcoded encryption keys.

## 3. Sandboxed Storage & Invariant Paths
- Never hardcode absolute file paths containing Android user IDs (`/data/user/0/...` or `/storage/emulated/0/...`).
- Store all media attachments and snapshots using app sandbox paths obtained via `getApplicationDocumentsDirectory()`.
- Use relative paths in database records (`images/img_<timestamp>.jpg`) to ensure backups restore cleanly across device migrations.

## 4. Biometric Security & App Lock
- Biometric verification (fingerprint / face unlock / PIN) must gate access immediately upon app resume if lock is enabled.
- Lock timeout countdowns must reset upon backgrounding.
- PIN hashes must be salted and stored in `FlutterSecureStorage`.
