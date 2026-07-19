# NoteKar Evolution Implementation Plan

This plan outlines the steps to transform **NoteKar** into a production-quality Android application with enhanced features, improved UX, and solid architectural foundations.

## User Review Required

> [!IMPORTANT]
> **Reminder Support Implementation**: To ensure reliability, I propose using `flutter_local_notifications`. This requires adding a new dependency and handling Android 13+ notification permissions.

> [!TIP]
> **Architecture Refactor**: I recommend moving update logic, sensor management, and reminders into dedicated "Service" classes to reduce the complexity of `note_kar_home.dart` (currently 2400+ lines).

## Open Questions

1.  **Feedback System**: Should the feedback system send an email directly (using `mailto:`) or do you prefer a web-based form integration?
2.  **Swipe-Up Menu**: Should this gesture replace the existing Toolbar buttons for some users, or strictly be an *additional* shortcut?
3.  **Reminders**: Should they be simple "one-off" alerts, or do we need complex repeating logic (e.g., every 8 hours) immediately?

---

## Proposed Changes

### 1. Core Architecture & Refactoring

#### [MODIFY] [note_kar_home.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/screens/note_kar_home.dart)
- Extract update checking logic into a `UpdateService`.
- Extract sensor/shake logic into a `SensorService`.
- Implement `Swipe-Up` gesture detection on the main background `GestureDetector`.
- Update `_checkForUpdates` with the requested 3s loading and 1m reset logic.

#### [NEW] [reminder_service.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/services/reminder_service.dart)
- [NEW] Dedicated service for scheduling and managing local notifications.

---

### 2. UI & Interaction Improvements

#### [MODIFY] [note_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/note_dialog.dart)
- Increase `_maxChars` to **500**.
- Add a `ScrollController` to the `TextField` to ensure the cursor is always followed during long note entry.

#### [MODIFY] [calendar_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/calendar_dialog.dart)
- Compact grid spacing and padding to ensure the full month fits on smaller screens.
- Review `mainAxisExtent` and `SliverGridDelegate` parameters.

#### [MODIFY] [history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/history_dialog.dart)
- Update "Load older moments" card style (corner radius, elevation) to match `MomentTile`.

#### [MODIFY] [moment_tile.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/widgets/moment_tile.dart)
- Enhance visual consistency for IN/OUT highlights.

---

### 3. Feature Additions

#### [MODIFY] [settings_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/widgets/settings_widgets.dart)
- Add "Buy Me a Coffee" and "Report Issues" buttons to `SettingsAboutBlock`.

#### [MODIFY] [feedback_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/widgets/feedback_widgets.dart)
- Implement a simple "Bug Report / Feature Request" sheet.

#### [MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/utils/app_utils.dart)
- Icon Audit: Standardize icon selection across the app.

---

## Verification Plan

### Automated Tests
- Unit tests for `Moment` model length validation.
- Service tests for `UpdateService` timing logic.

### Manual Verification
- **Shake to Capture**: Verify threshold sensitivity on a physical device.
- **Swipe-Up**: Test gesture responsiveness and conflict with scrolling (if applicable).
- **Calendar**: Check layout on small (e.g., Pixel 4) vs large (e.g., Pixel 7 Pro) screen sizes.
- **Update Flow**: Manually trigger update check and time the UI states.
