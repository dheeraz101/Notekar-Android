# UI/UX Restoration & Stability Plan

Revert complex header/popup logic to stable versions and fix alignment inconsistencies across the app to restore a professional iOS feel.

## User Review Required

> [!IMPORTANT]
> **Layout Reversion:** I am removing the "Dynamic Large Title" (collapsing header) logic from `AppSheet`. It was creating inconsistent spacing and "ghosting" artifacts.
> - Sheets will now have a **fixed, stable header** with the title.
> - The Large Title will be moved back into the scrollable area as a simple bold header where appropriate, or removed if redundant.

> [!NOTE]
> **Note Dialog:** Reverting to the "Modularized Phase 4" version which was stable and correctly handled keyboard interactions without moving to the top of the screen or shrinking awkwardly.

## Proposed Changes

### 1. Stable Header Architecture
#### [MODIFY] [dialogs/app_sheet.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_sheet.dart)
- Revert to a simple `Column` layout.
- Header will contain: Handle -> Row(Title + Close Button).
- No more `Opacity` math or `Stack` layers. This ensures the title stays "attached" and doesn't overlap content.
- Remove `AppSheetLargeTitle` (or simplify it to a standard `Text` widget).

### 2. Dialog Restoration (Git Reversion)
#### [MODIFY] [dialogs/note_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/note_dialog.dart)
- Restore the original `AppSheet` wrapper.
- Remove `Material` / `Stack` / `Align` hack.
- Maintain the `_LinearCharacterIndicator` but restore original padding.

#### [MODIFY] [dialogs/history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/history_dialog.dart)
- Restore the selection indicator message to the bottom or as a simple card in the list, ensuring it doesn't cause layout jumps.
- Re-align filter chips to have consistent padding.

### 3. Spacing & Grid Alignment
#### [MODIFY] [dialogs/settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings_dialog.dart)
- Fix side spacing for list items.
- Ensure all category pages share the exact same `padding` and `constraints`.
- Restore standard `spacing16` to the root list.

### 4. Minimalist Lock Screen Refinement
#### [MODIFY] [dialogs/privacy_overlay.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/privacy_overlay.dart)
- Ensure the Unlock button is solid and minimal without any glowing shadows.

## Verification Plan

### Manual Verification
1. **Header Stability:** Scroll History/Settings; titles should remain fixed and not move or fade.
2. **Note Entry:** Open Note; verify it stays balanced above the keyboard.
3. **Transition Cleanliness:** Navigate Settings; verify no overlapping titles or ghosting elements.
4. **Spacing Check:** Verify all sheets have identical left/right alignment.
