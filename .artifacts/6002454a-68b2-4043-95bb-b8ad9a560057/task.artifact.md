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
- [x] **Increase Note Length**
  - [x] Update `maxNoteLength` to 500.
  - [x] Update character counter UI.
  - [x] Verify DB and Export/Import support for longer notes.
- [/] **Software Update Center (Apple Style)**
  - [ ] Create `UpdateCenterPage` widget with iOS-inspired layout.
  - [ ] Implement 5s minimum check animation logic.
  - [ ] Design "Up to date" and "Update available" dynamic states.
  - [ ] Integrate into `SettingsDialog` navigation stack.
  - [ ] Sync update status across main settings and detail page.
- [x] **Feedback System**
  - [x] Implement "Report a Bug" and "Request a Feature" logic.
  - [x] Integrate feedback triggers in Settings and About.
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
