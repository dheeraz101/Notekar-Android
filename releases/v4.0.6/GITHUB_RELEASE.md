# NoteKar 4.0.6

NoteKar 4.0.6 is a major quality, stability, and reliability release introducing offline background reminder resilience, a complete full-screen setup and onboarding swipe experience, an advanced Cupertino-style reminder message composer, and a secure timed factory reset sequence.

### Highlights

- **Resilient Background Reminders**: Elevates alarms to native system-level priority clocks (`AlarmManager.setAlarmClock()`), ensuring offline alerts trigger on time even if the app has been killed.
- **Interactive Onboarding Swipe Flow**: Introduces a clean full-screen onboarding guide to configure preferences and walk through permissions step-by-step.
- **Dynamic Update Walkthrough**: Existing users updating to 4.0.6 are shown the full-screen setup targeting ONLY the new Reminders page to introduce exact alarms.
- **Cupertino Reminder Message Composer**: Sleek Apple-style message composer sheet with current value view cards and a history queue of your 5 most recent messages.
- **Secured Staged Factory Reset**: Replaces instantaneous wiping with a timed 5-second secure sequence detailing databases, preferences, and alarm purging stages.
- **Manufacturer Auto-Start Configuration**: Integrates custom device settings hooks to easily allow Auto-Start on aggressive OEM systems (Xiaomi, Oppo, Vivo, Samsung, Huawei).

### Assets

- Universal: `notekar-4.0.6-universal.apk`
- ARM64: `notekar-4.0.6-arm64-v8a.apk`
- ARMv7: `notekar-4.0.6-armeabi-v7a.apk`
- x86_64: `notekar-4.0.6-x86_64.apk`
