# Settings Cleanup & Link Audit Plan

This plan aims to simplify the main settings page by removing status labels and providing an audit of all external links for final updates.

## User Review Required

> [!IMPORTANT]
> **Link Audit**: Below is the current list of external links found in the project. Please provide the updated URLs if any need changing.
> - **Official Site**: `https://notekarapp.vercel.app`
> - **GitHub Repo**: `https://github.com/dheeraz101/Notekar`
> - **GitHub Issues**: `https://github.com/dheeraz101/Notekar/issues`
> - **GitHub Releases**: `https://github.com/dheeraz101/Notekar/releases`
> - **Buy me a Coffee**: `https://buymeacoffee.com/dheeraz101`
> - **Support Email**: `mailto:yabp.ub8ke@aleeas.com`
> - **Notification Feed**: `https://raw.githubusercontent.com/dheeraz101/NotekarN/refs/heads/main/notification.json`

## Proposed Changes

### 1. Main Settings Cleanup
- **Update `SettingsDialog`**:
    - Remove the `status` parameter from all `SettingsRow` items in the **Root Settings Group** (Personalization, Logging, Privacy, Data, etc.).
    - This will create a cleaner, list-style look as requested.
    - Status labels *inside* sub-categories (like theme name inside Personalization) will remain unless otherwise specified.

### 2. Link Implementation
- Once the user provides the updated links, I will update the constants in `app_utils.dart` to reflect the production-ready URLs.

## Proposed Files

### [Component: UI]
#### [MODIFY] [settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/settings_dialog.dart)

### [Component: Utils]
#### [MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/utils/app_utils.dart)

## Verification Plan

### Manual Verification
- Open Settings and verify the main list is clean (no status text on the right side).
- Verify sub-categories still work as expected.
- Verify all external links lead to the new provided URLs.
