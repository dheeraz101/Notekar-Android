# iOS UI Polish & Logic Cleanup Plan

Refine the vertical alignment, fix title clipping in popups, redesign the history undo notification, and ensure every setting has a unique visual identity.

## User Review Required

> [!IMPORTANT]
> **Unique Icons:** I am performing a full audit of the settings menu to ensure no two settings share the same icon. This involves changing several common icons (like `tune` and `backup`) to more specific variants to improve "glanceability."
>
> **Full-Width Dividers:** Group card dividers will now touch the left side completely (removing the 64px indent). This creates a more solid, partitioned look matching the "Inset Grouped" aesthetic.

## Proposed Changes

### 1. Header & Title Fixes
#### [MODIFY] [dialogs/app_sheet.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_sheet.dart)
- In the `AppSheet` build method, wrap the header `Text` widget in a `FittedBox(fit: BoxFit.scaleDown)` with `maxLines: 1`.
- This prevents long titles like "Time Between Moments" from wrapping and being cut off.

### 2. History Undo Notification Overhaul
#### [MODIFY] [dialogs/history_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/history_dialog.dart)
- Update `_NoticePill` to use a translucent style for the text/button.
- Wrap it in a solid background container (pill style) that matches the width of the moment cards.
- Position remains floating above the moments.

### 3. Settings Visual Polish
#### [MODIFY] [widgets/settings_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart)
- **Dividers:** Remove `indent: 64` from `SettingsGroup` dividers.
- **Alignment:**
    - `SettingsRow`: Update icon margin to `top: 8` and title height to `3`.
    - `SettingsSwitchRow`: Update icon margin to `top: 8` and title height to `3`.
    - This provides a more balanced "middle-aligned" look that feels more native on high-DPI screens.

#### [MODIFY] [widgets/common_elements.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/common_elements.dart)
- Update `SettingsPageNote` padding to `EdgeInsets.symmetric(horizontal: 20, vertical: 12)`. This aligns the description text exactly with the left edge of the group cards.

### 4. Logic & Icon Cleanup
#### [MODIFY] [dialogs/settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings_dialog.dart)
- **Back Cards:** Change the arrow and label color from `p.accent` to `p.text` (or `p.text2`) for a cleaner, less "noisy" look.
- **Icon Audit:**
    - Personalization: `Icons.brush_rounded`
    - Data & Backup: `Icons.storage_rounded`
    - Backup & Export: `Icons.import_export_rounded`
    - Backup: `Icons.cloud_upload_rounded`
    - Updates: `Icons.update_rounded`
    - Help & Guides: `Icons.auto_stories_rounded`
    - Guides: `Icons.map_rounded`
    - Capture: `Icons.add_task_rounded`
    - Large Controls: `Icons.ads_click_rounded`
    - History Text: `Icons.format_list_bulleted_rounded`
    - Enable Translucency: `Icons.opacity_rounded`
    - Toolbar Backplate: `Icons.shape_line_rounded`
    - Advanced: `Icons.settings_suggest_rounded`
    - Reset Settings Only: `Icons.settings_backup_restore_rounded`

### 5. Changelog Padding
#### [MODIFY] [dialogs/changelog_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/changelog_dialog.dart)
- Add a `SizedBox(height: spacing64)` at the end of the `Column` in `ChangelogSettingsPage` to prevent the last card from touching the bottom.

## Verification Plan

### Manual Verification
1. **Title Test:** Open "Time Between Moments" duration; verify title fits perfectly.
2. **Undo Test:** Delete a moment; verify the new dual-pill style notification.
3. **Alignment Audit:** Verify that page notes start at the same vertical line as group cards.
4. **Icon Audit:** Browse settings and confirm every row has a unique, descriptive icon.
5. **Dividers:** Verify dividers now reach the left edge of the card.
6. **Changelog:** Verify the last card has plenty of breathing room at the bottom.
