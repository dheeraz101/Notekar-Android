# Changelog: NoteKar Android

All notable changes to NoteKar Android will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [4.0.6] - 2026-07-22 (versionCode 15)

### Added
- Reliable Background Reminders using Android's native alarm system for offline notifications.
- New full-screen Onboarding setup guide for permissions and preferences.
- Quick setup flow for existing users to configure Reminders and exact alarm permissions.
- Improved Apple-inspired Reminder Message Editor with history support.
- Enhanced Factory Reset with a clear step-by-step safety process.
- Auto-Start settings shortcuts for Xiaomi, Oppo, Vivo, Samsung, and Huawei devices.

## [4.0.5] - 2026-07-22 (versionCode 14)

### Added
- Dedicated Language settings page supporting English, Hindi, and Spanish localization options.
- Onboarding welcome sheet language selector for quick initial language selection.
- Recently Deleted moments view (Trash Bin) with individual restore, restore all, and empty trash controls.
- 30-day auto-purge policy banner for Recently Deleted moments.
- Standard SettingsBetaNote card and Beta disclaimer popup on the Language settings page.

### Fixed
- Optimum contrast-adjusted accent colors dynamically matching selected Light/Dark/AMOLED themes.
- Snappy category transitions (180ms) and synchronized header title fades.
- Hardened Factory Reset and Clear Data logic covering preferences, active/trash databases, and locales.
- Minimal neutral-colored Check for Updates card matching the overall app style.
- Localized settings search results indexing and matching for Spanish and Hindi keywords.
- Localized Guides and Help FAQ items to match the user's selected interface language.

---

## [4.0.4] - 2026-07-20 (versionCode 13)

### Added
- Native Android rebuild powered by Flutter.
- Offline-first local database persistence via Hive.
- Compatibility with standard Android OS Auto Backup (Google Drive system backup).
- Tap delay configuration controls (0s - 60s) to prevent accidental double taps.
- Dual operating modes: Two-Way (IN/OUT session tracking) and Single (one-shot timestamping).
- Data export features to CSV and JSON formats.
- Privacy-first permission controls (Internet for release checks & bug notices; Notifications for reminders).
- Sleek 8pt grid visual design system with macOS/iOS inspired dark, light, and AMOLED theme options.

---

## [3.2.7] - 2026-06-10

### Added
- Web PWA release with IndexedDB persistence.
- Offline Service Worker caching.
