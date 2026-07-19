# Implementation Plan - NoteKar Improvements (Phase 1 Refinements & Phase 2)

This plan outlines the refinements for Phase 1 based on user feedback and the continuation into Phase 2.

## User Review Required

> [!NOTE]
> **Single Mode Color**: Reverting to a dedicated blue (`p.blue`) for Single moments instead of the dynamic accent color.
> **Icons**: Reverting to `arrow_upward` (Single) and `swap_vert` (Two-Way).

## Phase 1 Refinements (UI/UX)

### 1. Calendar Dialog
- **[MODIFY] [calendar_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/calendar_dialog.dart)**
  - Reduce top spacing between month label and dates.
  - Ensure the last row of dates is fully visible.
  - Use `MainAxisAlignment.start` and tighter `SizedBox` heights.

### 2. Note Popup
- **[MODIFY] [note_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/note_dialog.dart)**
  - Fix the input area size. Instead of expanding, it will have a fixed height with internal scrolling.
  - Set `minLines` and `maxLines` to the same value or use a `ConstrainedBox`.

### 3. Icons & Colors Revert
- **[MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart)**
  - Change `momentColor` for `single` back to `p.blue`.
- **[MODIFY] [toolbar.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/toolbar.dart)**, **[moment_tile.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/moment_tile.dart)**, **[history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/history_dialog.dart)**
  - Revert `bolt` to `arrow_upward`.
  - Revert `sync_alt` to `swap_vert`.

### 4. Saved Pill (Home Tap)
- **[MODIFY] [feedback_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/feedback_widgets.dart)**
  - Increase `SavedPulse` width and padding to ensure "SINGLE saved" stays on a single line.

### 5. About Section Icons
- **[MODIFY] [settings_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart)**
  - Align all about icons in a single line.
  - Specific Order: Email → Report → Version Pill → Coffee → GitHub.
  - Use a `SingleChildScrollView` to prevent overflow on very small screens.

---

## Phase 2 — Function, Features & Logic
Implement core feature logic and performance-critical updates.

### Proposed Changes

#### [Component: Logic & Features]

- **[MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart)**
  - Increase `maxNoteLength` to 500.
- **[MODIFY] [note_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/note_dialog.dart)**
  - Update character counter to support 500 characters.
- **[MODIFY] [note_kar_home.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart)**
  - Implement timing logic for "Check for Updates" (3s loading, 1m reset).

---

## Verification Plan

### Automated Tests
- `flutter analyze`
- `flutter test`

### Manual Verification
- Verify Calendar last row visibility.
- Verify NoteDialog height is fixed.
- Verify About icons order and alignment.
- Verify "SINGLE saved" pill width.

