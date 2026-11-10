## NoteKar v7.5.15 (build 26BR1110)

Signed release — built automatically from the branch.

### What's New & Highlights

- **On-Device Offline Auto-Categorization**: 100% air-gapped Naive Bayes classifier trained exclusively on local notes. Features Unicode-aware tokenization preserving diacritics and matras across English, French, German, Spanish, Hindi/Devanagari, and CJK text without sending a single byte to external servers.
- **Universal Ledger Boundary Healing**: Mathematical reconciliation of overlapping session intervals in `UniversalIntervalLedger`, eliminating impossible chronological collisions and filtering zero-duration collapsed intervals without mutating raw moment records.
- **Multi-Category Target Allocations**: Define composite focus targets spanning multiple categories simultaneously in Goals & Targets. Category editing in `CreateOrEditGoalView` preserves multi-category selection cleanly without data loss.
- **Habit Checkpoints & DST Immunity**: Choose specific active days of week (1..7) for routine habits. Day progression calculations use calendar-exact stepping, eliminating Daylight Savings Time clock drift with hardened number deserialization.
- **Rune-Safe Full-Text Search with Fuzzy Matching**: Rune-safe Levenshtein distance 1 comparison comparing Unicode Runes, preventing surrogate-pair corruption when searching text containing non-BMP characters, regional scripts, and emojis.
- **Sovereign Vault Cryptographic Hardening (200k PBKDF2)**: Elevated key derivation to 200,000 PBKDF2-HMAC-SHA256 iterations for new sovereign `.notekar-vault` backups with backward-compatible 100k decryption. Enforced sandbox boundary path validation preventing `../` traversal.
- **Apple HIG Design & Squircle Token Unification**: Standardized `SettingsGroup` on `ContinuousSquircleBorder`, enforced 56.0pt inset dividers, 52pt button heights, OpenType tabular figures on live chronometers, and expanded all compact tap targets to meet or exceed 48×48dp (`NkTouchTarget.minInteractive`).
- **Android 15 Platform Parity & Background Maintenance**: Native C library 16KB memory page alignment verification, runtime exact alarm guards, internal broadcast receiver protection, and automated 30-day trash purging with database compaction during midnight maintenance.

### Integrity

- **Build Tag**: 26BR1110 (version 7.5.15+26111001)
- **Automated Tests**: All unit & widget tests passing (580/580 passing across 75 test suites, 0 failures, 0 lints)
- **Air-Gapped Sovereign Guarantee**: 0 network telemetry pings, 0 external trackers, 100% offline-first.
