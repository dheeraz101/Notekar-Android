# NoteKar 4.0.6

NoteKar 4.0.6 is a major quality, stability, and reliability release introducing offline background reminder resilience, a complete full-screen setup and onboarding swipe experience, an advanced Cupertino-style reminder message composer, and a secure timed factory reset sequence.

## Security

🛡️ **VirusTotal Status**: `Undetected by 68 engines`  
🔗 [View Full Report](https://www.virustotal.com/gui/file/a95a703eaf519bd0ddf1ab7839dab7a90a02150e7808882c3247cb35465a2bfe)  
📅 Last scanned: July 22, 2026

### Highlights

- **Resilient Background Reminders**: Elevates alarms to native system-level priority clocks (`AlarmManager.setAlarmClock()`), ensuring offline alerts trigger on time even if the app has been killed.
- **Interactive Onboarding Swipe Flow**: Introduces a clean full-screen onboarding guide to configure preferences and walk through permissions step-by-step.
- **Dynamic Update Walkthrough**: Existing users updating to 4.0.6 are shown the full-screen setup targeting ONLY the new Reminders page to introduce exact alarms.
- **Cupertino Reminder Message Composer**: Sleek Apple-style message composer sheet with current value view cards and a history queue of your 5 most recent messages.
- **Secured Staged Factory Reset**: Replaces instantaneous wiping with a timed 5-second secure sequence detailing databases, preferences, and alarm purging stages.
- **Manufacturer Auto-Start Configuration**: Integrates custom device settings hooks to easily allow Auto-Start on aggressive OEM systems (Xiaomi, Oppo, Vivo, Samsung, Huawei).

### Detailed Changelog

- **Added**: Full-screen Welcome and Onboarding experience (`WelcomeScreen`) with swipeable PageView.
- **Added**: Guided setup cards for exact alarms, notification permission, and manufacturer-specific Auto-Start settings.
- **Added**: Dynamic update walkthrough flow displaying only the reminders permission step to updating users.
- **Added**: Apple-style custom reminder message composer sheet supporting current value display, max 5 recent messages history queue, and empty/set status cards.
- **Added**: Rotating status icons and detailed sub-status phases to the 5-second Timed Factory Reset overlay.
- **Added**: Privacy notice to the bottom of the factory reset overlay explaining secure local data wiping.
- **Added**: Manual close ('x') settings button to the Auto-Start warning card to permanently hide it.
- **Improved**: Background reminder reliability using AlarmManager system-level priority clocks and WakeLock.
- **Improved**: Upgraded GitHub Action workflows to support Java 21 JDK Temurin distribution, package caching, AppBundle (`.aab`) generation, and CodeQL security configuration fixes.
- **Fixed**: Walkthrough launch state sequence check at app startup.
- **Fixed**: Suppressed automatic What's New changelog popups at startup for a cleaner upgrade experience.
