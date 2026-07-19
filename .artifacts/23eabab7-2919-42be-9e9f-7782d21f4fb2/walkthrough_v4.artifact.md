# Global Accessibility & iOS 18 Switch Walkthrough

I have implemented global scaling for "Larger Text", refined the "High Contrast" mode across all themes, and updated the switches to the wider iOS 18 aesthetic.

## Changes Applied

### 1. Global "Larger Text" Support
- **Centralized Logic:** Integrated text scaling directly into `AppSheet`. Now, **every dialog, history sheet, and popup** in NoteKar automatically respects the "Larger Text" setting without requiring individual code changes for new pages.
- **Home Screen Scaling:** Wrapped the main `Scaffold` in a `MediaQuery` that applies the user's preferred text scaling factor to the entire home screen, clock, and toolbar.
- **Unified Propagation:** Updated all call sites in `NoteKarHome` to pass the `largeText` state to dialogs, ensuring a seamless experience throughout the app.

### 2. High Contrast Refinement
- **Palette Boost:** Increased the brightness and visibility of borders and secondary text (`text2`, `text3`) in High Contrast mode, especially for **AMOLED** and **Dark** themes.
- **Overlay Consistency:** Updated the `PrivacyLockOverlay` to use high-contrast colors and support text scaling.
- **Toolbar Adjustment:** Refined the `Toolbar` border width in AMOLED high-contrast mode for better separation against pure black backgrounds.

### 3. iOS 18 Switch Refinement
- **Wider Thumb:** Updated `SettingsSwitchRow` with a more substantial, premium feel:
    - **Thumb Width:** Increased base width from 24 to 28.
    - **Stretch Factor:** Increased the "impact" stretch from 10 to 14 during taps.
    - **Switch Size:** Slightly increased the overall switch container width (52 to 58) and height to accommodate the larger thumb, mirroring the modern iOS 18 aesthetic.

## Verification
- **Scaling Audit:** Verified that "Larger Text" affects:
    - Main Screen & Clock
    - History & Search Sheets
    - Settings & Sub-pages
    - Note Editor & Backup Previews
    - "Time Between Moments" Popup
- **Contrast Check:** Confirmed that text is significantly more legible in High Contrast mode across all 3 themes.
- **Switch Test:** Verified the new wider thumb is smooth and visually premium in the settings menu.

> [!TIP]
> The "Larger Text" setting in NoteKar is designed to be intelligent: it respects your system-level font size but provides an additional boost for maximum clarity within the app.

> [!IMPORTANT]
> The wider switch thumb area also provides a slightly larger "hit area" (visual and physical) for better accessibility.
