# NoteKar Evolution - Implementation Plan

This plan outlines the architectural improvements and feature implementations to transition **NoteKar** into a polished, production-quality Android application.

## 1. Architectural Review & Recommendations

### Current State Analysis
- **Monolithic Structure**: `lib/main.dart` is ~8000 lines, containing all models, UI, and business logic. This hinders maintainability and scalability.
- **State Management**: Using `setState` in a massive `_NoteKarHomeState`. While performant for small apps, it leads to full-screen rebuilds for minor changes.
- **Navigation**: Custom overlay system instead of a formal router.
- **Performance**: Generally good due to Hive and minimal dependencies, but the monolithic build method and lack of modularity will cause "jank" as more features are added.

### Recommended Improvements
> [!IMPORTANT]
> **Modularization First**: Before implementing new features, I recommend splitting `main.dart` into a proper project structure. This will prevent the "8000-line file" from becoming even more unmanageable.

**Proposed Structure:**
- `lib/models/`: `Moment.dart`, `Backup.dart`, etc.
- `lib/theme/`: `Palette.dart`, `ThemeConfig.dart`.
- `lib/services/`: `StorageService.dart`, `NotificationService.dart`, `UpdateService.dart`.
- `lib/ui/components/`: `ClockFace.dart`, `Toolbar.dart`, `Ripple.dart`.
- `lib/ui/sheets/`: `HistorySheet.dart`, `SettingsSheet.dart`, `NoteDialog.dart`.
- `lib/ui/home/`: `NoteKarHome.dart`.

## 2. Feature Implementation Strategy

### [MODIFY] [main.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/main.dart)

#### 1. Increase Note Length
- **Target**: Increase `_maxChars` from 280 to 500 in `NoteDialog`.
- **Verification**: Ensure character counter updates and Hive handles the larger string (Hive has no practical limit for individual strings).

#### 2. Improve Text Input Scrolling
- **Implementation**:
    - Attach a `ScrollController` to the `TextField`.
    - Use `expands: true` or `maxLines: null` with careful height constraints.
    - Ensure the cursor remains visible by forcing a scroll to the cursor position on setiap `onChanged` event if necessary, though Flutter usually does this—I will investigate why it's currently failing (likely due to the fixed-height modal constraint).

#### 3. In-App Feedback
- **Implementation**: Add "Report a Bug" and "Request a Feature" to the `SettingsAboutBlock`.
- **Action**: These will open the user's email client with pre-filled diagnostic info (OS version, app version).

#### 4. Calendar Layout Improvements
- **Implementation**:
    - Adjust `MomentCalendarDialog` grid cell height.
    - Use `Flexible` or `Expanded` more effectively to prevent clipping.
    - Reduce vertical padding between week rows.

#### 5. Timeline Highlight Improvements
- **Implementation**:
    - Ensure `in` and `out` colors are used consistently in `HistoryDialog` and `MomentTile`.
    - Update `MomentTile` to use the accent color or specific type colors more prominently.

#### 6. Load More Card
- **Implementation**:
    - Refactor the "Load older moments" button in `HistoryDialog` to match `MomentTile`'s corner radius, height, and elevation.

#### 7. About Page Improvements
- **Implementation**:
    - Add "Buy Me a Coffee" and "Report Issues" buttons to `SettingsAboutBlock`.
    - Refine the layout to handle more buttons gracefully.

#### 8. Swipe-Up Menu (Gesture)
- **Implementation**:
    - Add a `GestureDetector` to the background of `NoteKarHome`.
    - Implement `onVerticalDragEnd` to detect upward swipes.
    - Show a lightweight `CupertinoActionSheet` or a custom bottom sheet with "History" and "Settings".

#### 9. Icon Audit
- **Implementation**: Review and replace `Icons` with more consistent Material symbols.

#### 10. Check for Updates Experience
- **Implementation**:
    - Update `_checkForUpdates` to ensure a minimum 3-second loading state using `Future.wait([fetch, Future.delayed(3s)])`.
    - Implement a `Timer` to reset the status to the default version info after 60 seconds of showing "You're up to date".

#### 11. Reminder Support
- **Architecture**: Create a `NotificationService` wrapper around `MethodChannel` or add `flutter_local_notifications`.
- **Recommendation**: Start with simple daily/weekly "Backup Reminders" and "Logging Reminders" via `AlarmManager` or simple local notifications.

#### 12. Shake to Capture
- **Implementation**:
    - Utilize existing `sensors_plus` stream in `_NoteKarHomeState`.
    - Implement a simple threshold-based shake detection logic (e.g., total acceleration > target).
    - Add a setting for "Shake Sensitivity".

---

## 3. Feasibility & Performance Assessment

| Feature | Feasibility | Performance Consideration |
| :--- | :--- | :--- |
| **Note Length** | High | Minimal impact. |
| **Scrolling** | High | Ensure no layout thrashing during typing. |
| **Swipe-Up** | High | Must not interfere with vertical scroll if a list is present. |
| **Shake Capture** | High | Must use low-frequency sensor sampling to preserve battery. |
| **Reminders** | Medium | Requires adding a new plugin or extending Android native code. |

## 4. Required Permissions & APIs
- **Notifications**: `Manifest.permission.POST_NOTIFICATIONS` (Android 13+).
- **Sensors**: Accelerometer (standard, no permission required).
- **Storage**: MediaStore (handled by existing implementation).

## 5. Phased Roadmap
1.  **Phase 1: Architecture Rewrite**: Modularize `main.dart` into logical components.
2.  **Phase 2: UI/UX Refinement**: Implement note length, scrolling, calendar, icons, and "Load More" styling.
3.  **Phase 3: Interactive Features**: Implement Swipe-up gesture, Shake to capture, and enhanced Update flow.
4.  **Phase 4: Support & Reminders**: Implement Feedback system and Reminder architecture.

## 6. Testing Strategy
- **Unit Tests**: Test backup validation logic and date formatting utilities.
- **Widget Tests**: Test `NoteDialog` character limits and `HistoryDialog` filters.
- **Integration Tests**: Verify the "Shake to Capture" trigger and "Swipe-up" gesture.
- **Manual QA**: Test calendar layout on small devices (e.g., 4-inch screens) and large tablets.

## 7. Edge Cases
- **Note Length**: Importing old backups with shorter notes.
- **Shake**: Accidental triggers while walking/driving (needs high threshold + lying-still check).
- **Reminders**: Handling device reboots (requires `RECEIVE_BOOT_COMPLETED`).

---

**Does this implementation plan align with your vision for NoteKar? I am ready to begin Phase 1 (Architectural Cleanup) upon your approval.**
