# Implementation Plan - NoteKar Improvements (Phase 3)

This plan outlines the final heavy features, gestures, and external system integrations for NoteKar.

## User Review Required

> [!CAUTION]
> **Dependency Update**: To implement Reminders, I will need to modify `pubspec.yaml` to include `flutter_local_notifications` and `timezone`. This requires a `flutter pub get` and a fresh build on your end once I apply the changes.
>
> **Gesture Interaction**: The Swipe-Up gesture is designed for speed but can overlap with system navigation. I will implement a safe vertical threshold and velocity check to ensure it only triggers when intended.

## Proposed Changes

### 1. Shake to Capture
- **Logic**: Use the `sensors_plus` package to monitor accelerometer data.
- **Trigger**: Detect a rapid movement sequence (shaking the phone) to immediately open the `NoteDialog`.
- **Settings**:
  - `Shake to Capture` (Toggle)
  - `Sensitivity` (Low, Medium, High slider)
- **Efficiency**: The sensor stream will only be active when the feature is enabled and the app is in the foreground.

### 2. Swipe-Up Quick Menu
- **Logic**: Integrate a vertical drag listener on the home screen tap area.
- **UI**: A lightweight, glassmorphic action sheet that slides up.
- **Quick Actions**:
  - History
  - Settings
  - Undo Last Moment
- **Setting**: `Swipe Up to Open` (Toggle, disabled by default).

### 3. Comprehensive Reminder System
- **Service**: Implement `ReminderService` using `flutter_local_notifications`.
- **Model**: Create a `Reminder` model with support for:
  - One-time alerts.
  - Repeating schedules (Daily, Weekly).
- **Storage**: Persist reminders in a dedicated Hive box (`notekar_reminders_v1`).
- **Integration**:
  - New **Reminders** category in Settings.
  - Interactive "Log Now" action button within the notification itself.

---

## Verification Plan

### Automated Tests
- `flutter analyze`
- Unit tests for `Reminder` serialization and scheduling logic.

### Manual Verification
- **Gestures**: Physically shake the device to trigger capture; swipe up to verify quick menu stability.
- **Reminders**: Set a 1-minute alert, close the app, and verify the notification appears with the action button.
