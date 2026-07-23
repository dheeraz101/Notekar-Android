# Changelog: NoteKar Android

All notable changes to NoteKar Android will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [4.0.9] - 2026-07-23 (versionCode 18) [Beta]

### Added
- Custom Markdown Text Renderer (`MarkdownText`) in settings for rich rendering of headers, lists, code, bold text, and hyperlinks.
- Double Action Buttons on the update checking card, supporting both "Install Now" and "Check for updates".
- Track Switch Downgrades explanation guide to the Help FAQ section.
- Polished numbering list inside the Build Choose page with baseline-aligned number columns.

### Fixed
- Resolved 404 download errors on Beta APK downloads by tracking tagNames in the update checker.
- Resolved VirusTotal pipeline size limit failures by fetching custom large-file upload URLs.
- Resolved Perl delimiter syntax warnings on release note generation scripts.
- Resolved update classification heuristic conflicts with markdown headers inside release bodies.
- Fixed version string layouts on the up-to-date panel to display version name alongside build codes.

## [4.0.8] - 2026-07-23 (versionCode 17) [Beta]

### Added
- Windows-Style Update Classification System dividing updates into Feature, Security, and Beta tracks with custom layouts.
- Dynamic Build Channel Badges displaying local build channel track status (Stable Build, Beta Build, or Security Build).
- Dynamic editing suffix icon in the reminder message editor toggling between edit and checkmark controls.
- 3-second transparent overlay modal with Cupertino Activity Indicators when switching release tracks.
- Upgraded version management scripts supporting automatic calculation increments via `-stable`, `-beta`, or `-security` switches.

## [4.0.7] - 2026-07-23 (versionCode 16)

### Added
- Integrated update installer downloading, verifying MD5 hashes, and installing releases in-app.
- Offline commits caching saving commit logs for offline viewing, warning users when loading offline.
- Dynamic VirusTotal reports showing clean scan ratios, scan execution dates, and verification color banners.
- Sleek Apple iOS 26 style CupertinoActivityIndicator widgets replacing CircularProgressIndicators.
- Settings search indexing support for track selection, security reports, and commits caches.
- Dynamic 999-to-32 radius card transitions inside the changelog sheet.

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
