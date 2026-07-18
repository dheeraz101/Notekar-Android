# Premium Moment Categorization & Notification Alignment Plan

Assign a dedicated permanent color to "Single" moments and synchronize the History notification position with the Home toolbar for global UX consistency.

## User Review Required

> [!IMPORTANT]
> **Single Moment Color:** I am strictly assigning **Dedicated iOS Blue** (`#007AFF` / `#0A84FF`) to all "Single" moments. They will no longer use the dynamic accent color. This ensures clear visual categorization: Green (IN), Orange (OUT), and Blue (SINGLE).
>
> **Notification Alignment:** I am moving the History "Undo" notification to match the exact vertical position of the home screen menu bar. To achieve this safely, I am updating the `AppSheet` component to correctly respect the system navigation bar (safe area).

## Proposed Changes

### 1. Dedicated "Single" Moment Color
#### [MODIFY] [widgets/moment_tile.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/moment_tile.dart)
- Update the `color` logic in `build` to use `momentColor(p, entry.type)`.
- This replaces the hardcoded `p.accent` with the dedicated `p.blue` defined in the palette.

#### [MODIFY] [widgets/feedback_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/feedback_widgets.dart)
- Update `_pulseLabel` to return `'SINGLE saved'` for non-directional moments.
- This ensures consistency in saved feedback.

### 2. History Notification Vertical Sync
#### [MODIFY] [dialogs/app_sheet.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_sheet.dart)
- Update `AppSheet` bottom padding to include `MediaQuery.paddingOf(context).bottom` when `docked` is true.
- This ensures the sheet content respects the Android navigation bar.

#### [MODIFY] [dialogs/history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/history_dialog.dart)
- Change the `Positioned` notification `bottom` value to **0**.
- Combined with the `AppSheet` fix, this will place the notification at exactly `16px + bottomInset` from the screen edge, mirroring the home toolbar.

## Verification Plan

### Manual Verification
1. **Color Audit:** Save a "Single" moment; verify it uses the permanent blue color and says "SINGLE saved".
2. **History Audit:** Verify that "Single" moments in the history list are Blue, regardless of what "Action Color" is selected in personalization.
3. **Alignment Audit:** Open History; verify the "Undo" pill floats at the same height as the home screen menu bar.
4. **Theme Test:** Check AMOLED mode to ensure the new blue color provides enough contrast (it uses the brighter `#0A84FF`).
