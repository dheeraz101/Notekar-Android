# Workflow 05: Regression Testing Gauntlet

> **Command**: `/test-regression`  
> **Objective**: Execute comprehensive regression testing across all 73+ test suites, checking state lifecycles, database integrity, and backwards compatibility.

---

## 1. Preconditions
- Flutter SDK available and dependencies installed (`flutter pub get`).
- Native Isar binary (`isar.dll` on Windows / `libisar.so` on Linux) available in root directory.

---

## 2. Test Execution Tiers

### Tier 1: Fast Smoke Tests (< 30 seconds)
Run high-signal core unit tests:
```powershell
flutter test test/accent_palette_test.dart test/widget_test.dart test/haptics_single_burst_test.dart test/clock_format_test.dart
```

### Tier 2: Domain Logic & Lifecycle Suites
Run comprehensive state and lifecycle tests:
```powershell
flutter test `
  test/life_ledger_timeline_test.dart `
  test/timeline_session_lifecycle.md `
  test/dual_soul_session_test.dart `
  test/gap_prefill_and_rest_test.dart `
  test/single_numbering_test.dart `
  test/checkpoint_habit_fixes_test.dart
```

### Tier 3: Apple HIG & Component Token Suites
Verify visual contracts and component integrity:
```powershell
flutter test `
  test/apple_hig_bitchord_precision_components_test.dart `
  test/apple_hig_experience_test.dart `
  test/settings_navigation_and_custom_switch_test.dart `
  test/search_bars_centering_test.dart
```

### Tier 4: Security, Storage & Migration Suites
Verify zero-data-loss and encryption:
```powershell
flutter test `
  test/vault_encryption_service_test.dart `
  test/migration_compatibility_test.dart `
  test/backup_import_test.dart `
  test/notekar_data_safety_permissions_content_rating_test.dart
```

### Tier 5: Full Suite Execution
Run all tests in repository:
```powershell
flutter test
```

---

## 3. Failure Triage Process
If any test in the gauntlet fails:
1. Capture the test name, failure reason, expected vs actual values, and stack trace.
2. Check `git diff` to see what changes were introduced since the last green baseline.
3. Determine if the failure is:
   - A genuine regression (code change broke an invariant).
   - An outdated test expectation that needs deliberate updating.
4. Resolve the failure until 100% pass rate is restored.

---

## 4. Completion Criteria
- 100% test pass rate across all test files.
- Zero skipped or ignored tests.
- Zero errors in static analysis.
