---
description: Mandatory standards for Android native behavior, predictive back, dynamic receivers, widgets, and notifications
globs: android/app/**/*.kt, android/app/**/*.xml, lib/widgets/**/*.dart, lib/services/**/*.dart
---

# 04 - Android Native Behavior & Integration Standard

## 1. System Broadcast Registration (API 26–36)
- **No Implicit Broadcasts in Manifest**: Android 8.0+ prohibits static manifest registration for implicit system intents (e.g. `ACTION_USER_PRESENT`).
- **Dynamic Export Flags**: When registering broadcast receivers at runtime, always specify `Context.RECEIVER_EXPORTED` or `Context.RECEIVER_NOT_EXPORTED` on API 33+ (Android 13+):
  ```kotlin
  ContextCompat.registerReceiver(
      context,
      receiver,
      filter,
      ContextCompat.RECEIVER_EXPORTED
  )
  ```
- **Sync on Startup**: Synchronize receivers across `MainActivity.configureFlutterEngine`, `ReminderReceiver`, and foreground services.

## 2. Notification System & Status Icons
- **Flat Monochrome Icons Only**: Always use `R.drawable.ic_stat_notekar` for `NotificationCompat.Builder.setSmallIcon()`.
- **Never Use Launcher Mipmaps**: Never pass `R.mipmap.*` adaptive XML icons as small notification icons; this causes fatal crashes or silent notification drops on Samsung, Pixel, and Xiaomi devices.
- **Action Title Length**: Keep notification action titles under 8 characters (e.g., `📝 Log`, `🏷️ Modes`, `▶ Start`, `⏹ OUT`).
- **Action Intent Cap**: Never add more than 3 actions to a notification to prevent OEM layout truncation.

## 3. RemoteViews & App Widget Sync
- Home screen app widgets (`NoteKarWidgetProvider`, `SessionWidgetProvider`, `SobrietyWidgetProvider`) must stay responsive even when the Flutter isolate is suspended.
- Background widget clicks must update both `FlutterSharedPreferences` AND `widgetPrefs`, then call `updateAllWidgets(context)` immediately.
- Widgets must never freeze waiting for the Flutter isolate to spin up.

## 4. Predictive Back & Edge Gestures
- Support Android 14+ Predictive Back gestures.
- Custom edge gesture recognizers (`PredictiveBackPeek`) must filter pointers in `addAllowedPointer()` before entering the gesture arena (`localPosition.dx <= edgeWidth`) to avoid blocking horizontal scrollables.

## 5. Navigation & Screen Transitions
- Use native Android Material 3 zoom transitions configured via `ZoomPageTransitionsBuilder()` for `TargetPlatform.android`.
- Hardware back button must cleanly dismiss bottom sheets and dialogs without state corruption.
