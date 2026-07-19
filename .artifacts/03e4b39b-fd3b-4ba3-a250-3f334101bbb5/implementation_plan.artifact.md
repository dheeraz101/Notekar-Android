# iOS Header Polish & Typography Standardization Plan

Complete the high-fidelity iOS Pro transformation by adding circular backgrounds to all header actions and standardizing typography across all settings pages.

## User Review Required

> [!IMPORTANT]
> **Circular Header Actions:** I am standardizing the Back and Close buttons in all sheets to use a professional 32px circular background (`p.surface3`). This provides better tap targets and a premium "System App" feel.
>
> **Typography Audit:** I am performing a full scan of the settings menu to ensure every page uses the `SettingsPageNote` component with a strict **16px horizontal padding**. This ensures all descriptions align perfectly with the card content above them.

## Proposed Changes

### 1. Circle Backgrounds for Header Buttons
#### [MODIFY] [dialogs/app_sheet.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_sheet.dart)
- Verify `_HeaderCircleButton` is used for both `onBack` and the default Close button in the `Stack`.
- This ensures all popups (Settings, History, Calendar, etc.) have consistent circular action buttons.

### 2. Standardized Page Descriptions
#### [MODIFY] [widgets/common_elements.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/common_elements.dart)
- Refine `SettingsPageNote` text style:
    - Font Size: **13px**
    - Line Height: **1.35**
    - Color: **p.text3** (Softer gray to match iOS footer style)
- Ensure horizontal padding remains strictly **16px**.

#### [MODIFY] [dialogs/settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings_dialog.dart)
- **Replace Raw Text:** Find the one remaining raw `Text` widget in the "Reset" sliver and replace it with `SettingsPageNote`.
- This ensures the 16px padding is global across all 15+ settings sections.

### 3. Large History Notifications (Fidelity Polish)
#### [MODIFY] [dialogs/history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/history_dialog.dart)
- Increase `_NoticePill` scale further:
    - Vertical padding to **14px**.
    - Font size to **15px** with **900 weight**.
- This makes the Undo notification feel like a primary system event.

## Verification Plan

### Manual Verification
1. **Circle Buttons:** Open Settings categories and Calendar; verify both top-left and top-right actions have circular backgrounds.
2. **Alignment Audit:** Verify that "Personalization", "Logging", and "Reset" descriptions all start at the exact same 16px indent.
3. **Typography Check:** Confirm the text color in footers is a softer gray (`p.text3`) compared to the main labels.
4. **Notice Scale:** Delete a moment and verify the notification feels prominent and proportional to the tiles.
