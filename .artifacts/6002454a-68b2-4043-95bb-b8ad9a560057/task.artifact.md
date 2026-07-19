# Task List - NoteKar Improvements

## Phase 1 — UI/UX & Visual Refinements
- [x] **Calendar Improvements**
  - [x] Adjust `MomentCalendarDialog` vertical spacing (week rows, labels).
  - [x] Optimize `mainAxisExtent` and grid height for full row visibility.
- [x] **Timeline Consistency**
  - [x] Update `momentColor` to use dedicated blue for Single mode.
  - [x] Revert icons to `arrow_upward` and `swap_vert`.
- [x] **Load More Card Consistency**
  - [x] Match `borderRadius` and elevation with `MomentTile`.
- [x] **About Page Improvements**
  - [x] Add "Buy Me a Coffee" and "Report Issues" buttons.
  - [x] Align icons in a single line (Email → Report → Version → Coffee → GitHub).
- [x] **Note Input Experience**
  - [x] Fix input area height (non-expanding).
  - [x] Improve scrolling in `NoteDialog` TextField to follow the cursor.
- [x] **Saved Pill Width**
  - [x] Increase `SavedPulse` width for single-line text.
- [x] **Search Notes UI Refresh**
  - [x] Implement Apple HIG card style for notes.
  - [x] Show all notes when search query is empty.
- [x] **Verification**
  - [x] Run `flutter analyze`.
  - [x] Perform build test.
  - [x] Present for manual verification.

## Phase 2 — Function, Features & Logic
- [ ] **Increase Note Length**
  - [ ] Update `maxNoteLength` to 500.
  - [ ] Update character counter UI.
  - [ ] Verify DB and Export/Import support for longer notes.
- [ ] **Check for Updates Logic**
  - [ ] Implement 3s minimum loading state.
  - [ ] Implement 1m "Up to Date" reset timer.
- [ ] **Feedback System**
  - [ ] Implement "Report a Bug" and "Request a Feature" logic.
- [ ] **Verification**
  - [ ] Run `flutter analyze`.
  - [ ] Perform build test.
  - [ ] Present for manual verification.

## Phase 3 — Heavy Features & Gestures
- [ ] **Gesture Support**
  - [ ] Implement **Swipe Up to Open** action sheet.
  - [ ] Implement **Shake to Capture** with sensitivity settings.
- [ ] **Reminder System**
  - [ ] Integrate `flutter_local_notifications`.
  - [ ] Implement reminder architecture and UI.
- [ ] **Verification**
  - [ ] Run `flutter analyze`.
  - [ ] Perform build test.
  - [ ] Present for manual verification.
