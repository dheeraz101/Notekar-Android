# Implementation Plan - NoteKar Improvements (Phase 1 Refinements & Phase 2)

This plan outlines the refinements for Phase 1 based on user feedback and the continuation into Phase 2, including the new Update Center.

## User Review Required

> [!IMPORTANT]
> **Update Center UI**: I am proposing a dedicated "Software Update" style page that mirrors the iOS Settings aesthetic. This will replace the simple row-click behavior with a more interactive experience.

## Phase 1 Refinements (UI/UX) - COMPLETE
- [x] Calendar Dialog adjustments.
- [x] Note Popup fixed height.
- [x] Icons & Colors revert.
- [x] Saved Pill width fix.
- [x] About Section icons alignment.

---

## Phase 2 — Function, Features & Logic (IN PROGRESS)
Implement core feature logic and performance-critical updates.

### Proposed Changes

#### [Component: Logic & Features]

- **[MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart)**
  - Increase `maxNoteLength` to 500. [DONE]
- **[MODIFY] [note_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/note_dialog.dart)**
  - Update character counter to support 500 characters. [DONE]
- **[MODIFY] [note_kar_home.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart)**
  - Implement timing logic for "Check for Updates" (3s loading, 1m reset). [DONE]

### [NEW] Update Center (Apple HIG Style)
Refactor the update flow into a dedicated interactive sub-page within Settings.

- **[NEW] Update Center UI**:
  - Centered App Icon with glassmorphism.
  - "Software Update" title and status labels.
  - **Check for Updates Button**: A prominent primary button to trigger the check.
  - **Animation**: A high-fidelity 5-second loading sequence (spinner/shimmer).
  - **Dynamic Results**:
    - **Success (Update)**: "Version x.x.x is available" with release notes summary and a "Download from GitHub" button.
    - **Success (Current)**: "NoteKar is up to date" with a large checkmark icon.
- **[MODIFY] [SettingsDialog]**:
  - Update the "Updates" category row to navigate to this new interactive page.
  - Ensure the "Updates" row status (e.g., "Check for Updates" vs "You're up to date") syncs globally.

---

## Phase 3 — Heavy Features & Gestures
- **Gesture Support**: Swipe Up to Open, Shake to Capture.
- **Reminder System**: Foundational architecture and UI.

---

## Verification Plan

### Automated Tests
- `flutter analyze`
- `flutter test`

### Manual Verification
- **Update Center**: Trigger a check, verify the 5s animation, and check the "Up to date" vs "Update available" UI.
- **Status Sync**: Verify that performing a check on the Updates page updates the subtitle in the main Settings list.
