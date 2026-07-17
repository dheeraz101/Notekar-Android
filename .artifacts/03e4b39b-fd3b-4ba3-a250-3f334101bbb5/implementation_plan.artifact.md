# Inter Font (iOS Alternative) Integration Plan

Implement the Open Source **Inter** font family to achieve a premium, iOS-like aesthetic while remaining legally safe and fully offline.

## User Review Required

> [!IMPORTANT]
> I will use PowerShell to download the official font files directly into your project.
> - **Destination:** `assets/fonts/`
> - **Font Family Name:** `Inter`
> - **Impact:** Adds ~1MB to the app size but ensures a professional, consistent look across all Android devices.

## Proposed Changes

### 1. Font Acquisition (Automated)
- [EXECUTE] Create `assets/fonts/` directory.
- [EXECUTE] Download `Inter-Regular.ttf`, `Inter-Bold.ttf`, and `Inter-Italic.ttf` using `Invoke-WebRequest`.

### 2. Asset Registration
#### [MODIFY] [pubspec.yaml](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/pubspec.yaml)
- Register the `Inter` font family.
- Map files to weights (400 for Regular, 700 for Bold).

### 3. Global Theming
#### [MODIFY] [main.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/main.dart)
- Set the global `fontFamily` to `'Inter'`.
- Remove the previous `'SF Pro'` placeholder to ensure the app builds immediately.

### 4. Visual Refinement
#### [MODIFY] [app_utils.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart)
- Fine-tune `letterSpacing` for large titles to better mimic the iOS "Display" variants.

## Verification Plan

### Automated Tests
- `flutter analyze` to ensure the font family name matches exactly.

### Manual Verification
1. **Typography Check:** Verify that text looks "cleaner" and more balanced compared to Roboto.
2. **Offline Check:** Ensure the font works immediately upon launch without an internet connection.
3. **Weight Check:** Verify that headers (Bold) are distinct from body text.
