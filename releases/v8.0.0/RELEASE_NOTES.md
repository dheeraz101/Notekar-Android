# NoteKar v8.0.0 — Major Stable Release

**Build**: `26SR1115` (`version 8.0.0+26111501`)  
**Release Date**: November 15, 2026  
**Channel**: Production Stable  
**Status**: Signed & Verified Release (0 errors, 0 lints, 589/589 automated tests passed)  

---

## Executive Summary

NoteKar 8.0.0 represents a landmark evolution in sovereign, offline-first personal time tracking. This release unifies on-device machine intelligence, mathematical interval ledger reconciliation, OWASP-grade vault cryptography, and the aesthetic refinement of Apple Human Interface Guidelines tailored authentically to Android.

---

## 🌟 Major Highlights & New Capabilities

### 1. On-Device Offline Auto-Categorization Engine
- 100% air-gapped Naive Bayes classifier trained exclusively on local user notes.
- Multilingual Unicode-aware tokenization (`\p{L}`, `\p{M}`, `\p{N}`) preserving diacritics, matras, and regional scripts across English, Hindi/Devanagari, Spanish, German, French, and CJK text.
- Zero network permissions: not a single byte leaves the physical device.

### 2. Universal Interval Ledger Boundary Healing
- Mathematical reconciliation of overlapping sessions ($Start_B < End_A$) in `UniversalIntervalLedger`.
- Eliminates impossible chronological collisions and collapses zero-duration ghost intervals without mutating raw moment records.

### 3. Multi-Category Target Allocations
- Configure composite focus targets spanning multiple categories simultaneously in Goals & Targets.
- Safe category editing in `CreateOrEditGoalView` preserving multi-category selections without data loss.

### 4. Habit Checkpoint Custom Frequencies & DST Immunity
- Custom active days of week (`1..7`) for routine habits.
- Day progression calculations use calendar-exact stepping, eliminating Daylight Savings Time clock drift.
- Deserialization hardened against dynamic numbers.

### 5. Rune-Safe Full-Text Search with Fuzzy Matching
- Levenshtein distance 1 comparison operating on Unicode `Runes`, preventing surrogate-pair corruption when searching text containing non-BMP characters and emojis.

### 6. Sovereign Vault Cryptographic Hardening (200k PBKDF2)
- Key derivation elevated to 200,000 PBKDF2-HMAC-SHA256 iterations for newly exported `.notekar-vault` backups with backward-compatible 100k decryption.
- Strict sandbox boundary validation preventing `../` path traversal attacks in imported archives.

### 7. Apple HIG Design & Uniform 28pt Card Geometry
- Restored uniform 28pt rounded card geometry (`NkTokens.radii.card = 28pt`) across all `SettingsGroup` containers and habit dashboard cards, eliminating Flutter `ContinuousRectangleBorder` squarish corner artifacts.
- Enforced 56.0pt inset dividers, 52pt button heights, and 48×48dp minimum touch slop (`NkTouchTarget.minInteractive`).
- Tabular figures (`FontFeature.tabularFigures()`) across all live session chronometers.

### 8. Robust Intra-Dialog Scroll Memory & Dismissal Reset
- Specialized `_SettingsScrollController` and `_SettingsScrollPosition` providing synchronous dual-store restoration across in-dialog navigation tiers.
- Seamlessly remembers scroll offset when navigating into sub-categories (e.g., Updates & Notices → What's New → Back) while cleanly resetting to top (`0.0`) on full dialog dismissal.

### 9. Android 15 Platform Parity & System Maintenance
- 16KB memory page alignment verification for native C libraries.
- Runtime exact alarm guards (`canScheduleExactAlarms()`) and protected internal broadcast receivers (`RECEIVER_NOT_EXPORTED`).
- Automated 30-day trash purging and Isar database compaction integrated into background midnight `Workmanager` maintenance.

---

## 🛠️ Refinements & Bug Fixes

- **Dark Mode Session Surface Integrity**: Active session colors modulate the interactive `accent` token cleanly without inverting Dark/AMOLED canvas to white.
- **System Status Bar Visibility**: Status bar icon brightness strictly tracks the true theme canvas, ensuring light icons remain visible on dark session backdrops.
- **Streamlined 2-Way Controls**: Suppressed persistent bottom undo toast during active 2-way live sessions.
- **Centered Stop Pill**: Rendered accessible centered Stop pill directly below the intentional capsule when habits are disabled.
- **Apple HIG Minimalist Experience**: Condensed text layouts across Accent Color Sanctuary, App Icons dock header, Data Safety privacy nutrition labels, and App Philosophy.
- **Personal Profile Customizations**: Added Personal Intent Mantra input, Core Focus Domain horizontal selector, and Share Mantra on Profile Card toggle.
- **Official Bulletins & Changelog Redesign**: Removed redundant zero-tracking guarantee box; streamlined What's New with focused cards and added "View Previous Versions" link on Changelog.
- **Time-Awareness & Concurrency Segmented Control**: Upgraded logging concurrency configuration to an Apple HIG Cupertino sliding segmented control (`[ Auto-Pause | Parallel ]`).
- **Settings Dark Theme Search Bar Artifact Fix**: Eliminated rectangular container clipping block behind search bar in Dark theme (`#0B0F19`).
- **Guide & Help Deduplication**: Deduplicated content with Apple HIG squircle icon badges and Cupertino accordions.

---

## 🔒 Verification & Air-Gap Compliance

- **Zero Network Permissions**: NoteKar requires zero internet permissions (`android.permission.INTERNET` is absent from `AndroidManifest.xml`).
- **Test Gauntlet**: 589/589 automated tests passing (100% pass rate).
- **Static Analysis**: `flutter analyze --fatal-infos --fatal-warnings` — 0 errors, 0 warnings.
- **Code Formatting**: `dart format` — 100% clean.
