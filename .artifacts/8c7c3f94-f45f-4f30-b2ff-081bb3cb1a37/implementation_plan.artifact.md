# Release Readiness: UX, Legal & Versioning Plan

This plan outlines the final steps to ensure Notekar is ready for public release, focusing on a seamless launch experience, legal compliance, and proper versioning.

## User Review Required

> [!IMPORTANT]
> **Privacy Policy Content:** I will implement a standard, offline-first Privacy Policy dialog. Since Notekar is local-only (except for update checks), the policy will emphasize that your data never leaves the device.

## Proposed Changes

### 1. UX: Splash Screen Sync (Android)
- **Goal:** Prevent the "white/black flash" when the app starts by matching the system splash screen with the app's internal background.
- **Action:**
    - Create `colors.xml` in Android resources defining `#121212` (Dark background).
    - Update `styles.xml` and `launch_background.xml` to use this color instead of pure black, ensuring a smooth transition into the Flutter UI.

### 2. Legal: Licenses & Privacy
- **Open Source Licenses:**
    - Add a new row to the **Help & Guides** settings page.
    - Tapping this will trigger Flutter's built-in `showLicensePage`, which automatically lists all package licenses.
- **Privacy Policy:**
    - Create a new `PrivacyPolicyDialog` component.
    - Add a row to **Help & Guides** to open this dialog.
    - The policy will clearly state:
        - Data is stored locally using Hive.
        - No analytics or tracking.
        - Internet is only used for GitHub update checks and optional app notices.

### 3. Versioning
- **Action:** Increment the build number in `pubspec.yaml` from `4.0.3+12` to **`4.0.3+13`**.
- **Reason:** App stores require a unique, incremented build number for every release submission.

## Proposed Files

### [Component: Android Native]
#### [NEW] [colors.xml](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/android/app/src/main/res/values/colors.xml)
#### [MODIFY] [styles.xml](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/android/app/src/main/res/values/styles.xml)
#### [MODIFY] [launch_background.xml](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/android/app/src/main/res/drawable/launch_background.xml)

### [Component: UI & Legal]
#### [NEW] [privacy_policy_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/privacy_policy_dialog.dart)
#### [MODIFY] [settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/settings_dialog.dart)

### [Component: Metadata]
#### [MODIFY] [pubspec.yaml](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/pubspec.yaml)

## Verification Plan

### Manual Verification
- **Startup:** Launch the app on an Android device/emulator and verify there is no color flickering during the splash transition.
- **Licenses:** Open Settings -> Help & Guides -> Open Source Licenses. Verify the list of packages appears correctly.
- **Privacy:** Open Settings -> Help & Guides -> Privacy Policy. Read through the text to ensure it accurately reflects Notekar's offline nature.
- **Version:** Check the "About" footer or diagnostics to confirm the version is `4.0.3+13`.
