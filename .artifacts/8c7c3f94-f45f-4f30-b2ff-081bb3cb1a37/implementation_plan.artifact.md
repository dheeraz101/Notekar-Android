# Notekar Core Logic & Robustness Upgrade Plan

This plan aims to refactor the core business logic, data persistence, and native communication to be more resilient, maintainable, and powerful.

## User Review Required

> [!IMPORTANT]
> **Architectural Shift:** I propose moving the core moment-saving and history-filtering logic out of the `NoteKarHome` widget and into a dedicated `MomentRepository`. This will significantly reduce the complexity of the main screen and make the app more stable.
>
> **Data Safety:** I will implement a formal "Schema Migration" strategy for Hive to ensure that future updates to the data model don't cause crashes or data loss for existing users.

## Proposed Changes

### 1. Robust Data Layer (`MomentRepository`)
- **Decoupling**: Create a `MomentRepository` class to encapsulate all Hive and SharedPreferences operations.
- **Atomic Operations**: Ensure that saving a moment and updating the "next ID" or "last saved" state happens atomically to prevent data corruption.
- **Validation**: Add strict validation to the `Moment` model (e.g., preventing future timestamps or invalid types).

### 2. Enhanced Backup Engine
- **Versioning**: Add a `version` field to the backup JSON to allow for future schema evolutions.
- **Deep Validation**: Use a recursive validation approach for backup imports, providing specific error messages for corrupted rows.
- **Safe Merging**: Improve the "duplicates skipped" logic to handle cases where moments have identical timestamps but different notes.

### 3. Service-Based Logic
- **Haptic Service**: Move haptic logic to a dedicated service that can be mocked for tests.
- **Update Service**: Refactor the GitHub release checking logic into a reusable service with better retry-on-failure handling.

### 4. Resilient Native Bridge
- **Result Persistence**: Improve `MainActivity.kt` to handle "Result already active" errors more gracefully.
- **Type Safety**: Use more explicit type checks for arguments passed via `MethodChannel`.

### 5. Unified Error Logging
- **AppLogger**: Implement a simple internal logger that replaces empty `catch` blocks.
- **Diagnostic Export**: Include these internal logs in the "Copy Diagnostics" feature to help with remote debugging.

## Proposed Files

### [Component: Data & Models]
#### [NEW] [moment_repository.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/utils/moment_repository.dart)
#### [MODIFY] [moment.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/models/moment.dart)

### [Component: Services & Utils]
#### [MODIFY] [backup_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/utils/backup_utils.dart)
#### [MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/utils/app_utils.dart)

### [Component: UI Integration]
#### [MODIFY] [note_kar_home.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/screens/note_kar_home.dart)

### [Component: Native]
#### [MODIFY] [MainActivity.kt](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt)

## Verification Plan

### Automated Tests
- **Repository Tests**: Unit test the `MomentRepository` for all CRUD operations and edge cases (empty data, duplicates).
- **Migration Tests**: Verify that old data formats are correctly migrated to the new schema.
- **Backup Tests**: Run a suite of "Damaged JSON" imports to ensure no crashes occur.

### Manual Verification
- **Stress Test**: Rapidly tap to save 100+ moments and verify data integrity.
- **Import/Export**: Export a full backup, reset the app, and import it back to verify 100% data recovery.
- **Diagnostic Log**: Verify that failed update checks or network errors appear in the diagnostics text.
