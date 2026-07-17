# Minimal Moment Options Feature Plan

Add a "Minimal Moment Options" setting that simplifies the moment action sheet into a sleek, horizontal row of icons for a faster, more aesthetic experience.

## User Review Required

> [!NOTE]
> This feature will transform the large button pills in the "Moment Options" dialog into a single horizontal row of icons. This is perfect for power users who want a less cluttered interface.

## Proposed Changes

### 1. Persistent State
#### [MODIFY] [screens/note_kar_home.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart)
- Add `_minimalMomentOptions` state variable.
- Load from/Save to `SharedPreferences` as `m-minimal-moment-options`.
- Pass the flag down to `HistoryDialog`.

### 2. Setting Toggle & Search Index
#### [MODIFY] [dialogs/settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings_dialog.dart)
- Add `minimalMomentOptions` toggle in the "Moments" settings page.
- Update `_settingsSearchResults` with keywords: `minimal`, `icons`, `moment actions`, `compact`.
- Add a new row to the "Guides" section explaining how to use minimal moment options.

### 3. Dialog UI Refactoring
#### [MODIFY] [dialogs/history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/history_dialog.dart)
- **HistoryDialog:** Accept `minimalMomentOptions` parameter.
- **MomentActionsDialog:**
    - Accept `minimal` parameter.
    - **Normal Mode:** Existing pill-button layout.
    - **Minimal Mode:** A single `Row` of three circular icon buttons (Edit, Delete Note, Delete Moment).
    - Implement "Tap to Confirm" logic for the Delete icons in Minimal mode to maintain safety.

## Verification Plan

### Manual Verification
1. **Toggle Test:** Enable "Minimal Moment Options" in Settings.
2. **Visual Check:** Long-press a moment in History. Confirm the options appear as a single row of icons.
3. **Safety Check:** Tap the Delete icon in minimal mode; confirm it asks for a second tap to proceed (if Confirm Delete is on).
4. **Search Check:** Type "minimal" in Settings search; confirm the setting appears.
