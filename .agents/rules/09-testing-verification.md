---
description: Mandatory standards for test execution, static analysis, zero-lint policy, and verification gates
globs: **/*.dart, test/**/*.dart, scripts/*.ps1
---

# 09 - Testing & Verification Standard

## 1. Zero-Lint & Zero-Warning Mandate
Before completing any task, proposing changes, or preparing a Git commit:
1. Run static analysis:
   ```powershell
   flutter analyze --fatal-infos --fatal-warnings
   ```
   **Acceptance Criteria**: 0 errors, 0 warnings, 0 fatal infos.
2. Check formatting:
   ```powershell
   dart format --output=none --set-exit-if-changed lib/ test/
   ```
   **Acceptance Criteria**: Exit code 0.

## 2. Automated Test Suite Integrity
- Run the full test suite or relevant test group:
   ```powershell
   flutter test
   ```
- Every modified component, service, or model must be accompanied or verified by an automated test in `test/`.
- **Zero Test Regressions**: If a test fails after your change, you must resolve the regression. Never delete, comment out, or weaken test assertions.

## 3. Database & Isar Test Setup
- In unit and widget tests interacting with Isar models, ensure native binaries (`isar.dll` / `libisar.so`) are loaded or use in-memory mocked repositories.
- Never write tests that leave lingering temporary files in `test/` without cleaning them up in `tearDown()`.

## 4. Pre-Push Quality Gate
Always execute NoteKar's full local verification script prior to pushing:
```powershell
.\scripts\verify.ps1
```
This script runs the 3-step quality gate: formatting check, fatal static analysis, and full automated test suite.
