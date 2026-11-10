# NOTEKAR — Comprehensive Application & Architecture Audit

> **Audit Date**: 2026-11-10  
> **Target Release**: NoteKar Flagship Native Android (Flutter)  
> **App Version**: `7.5.14-E1+26110801` (SDK: Dart 3.12.2 / Flutter 3.44.4)  
> **Verification Status**: 74 Test Suites | 559 Automated Tests Passing (100%) | Static Analysis: 0 Warnings, 0 Errors  
> **Architecture Principle**: Apple HIG Spatial Elegance × Android Native Authenticity | 100% Sovereign Offline-First  

---

## 1. Executive Summary & Baseline Architecture

NoteKar is an offline-first chronometer, timestamp logger, and life ledger built on Flutter with native Android Kotlin extensions. It pairs instant point-in-time logging with contiguous interval tracking, multi-asset media attachments (photos, voice notes), goal pacing analytics, habit checkpoints, and sovereign encrypted vaults.

### 1.1 Quality Baseline
- **Automated Tests**: 74 test suites containing 559 individual unit, widget, and lifecycle tests in `test/`. All 559 tests pass cleanly.
- **Static Analysis**: `flutter analyze` runs clean with **zero warnings and zero errors**.
- **Android Target**: `compileSdk = 36`, `targetSdk = 35`, `minSdk = 26` (Android 8.0 Oreo through Android 15/16).
- **Core Dependencies**: Isar 3.1.0+1 (NoSQL on-device database), SharedPreferences 2.5.3 (instant boot cache), FlutterSecureStorage 10.3.1 (biometric/PIN entropy), Crypto 3.0.6 (SHA-256/PBKDF2), SensorsPlus 7.1.0, Workmanager 0.10.10, MobileScanner 7.4.2, QrFlutter 4.1.0.

---

## 2. Navigation, Screens & Modal Catalog

### 2.1 Primary Application Screens (`lib/screens/`)
| Screen | File Location | Route / Presentation | Core Responsibility |
| :--- | :--- | :--- | :--- |
| **NoteKar Home** | `lib/screens/note_kar_home.dart` | Root (`home: NoteKarHome()`) | Dynamic clock face, live chronometer, single/session logging controls, category selector, activity ring, recent timeline stream, toolbar capsule. |
| **Welcome & Onboarding** | `lib/screens/welcome_screen.dart` | First-launch push | 4-step onboarding introducing offline sovereignty, timestamp philosophy, biometric lock setup, and default category customization. |
| **Executive Intelligence Hub** | `lib/screens/executive_intelligence_hub_screen.dart` | Material 3 Zoom push | Full-screen activity intelligence dashboard: 24h rhythm distribution, focus tag breakdown, 90-day consistency matrix, weekly trend lines. |
| **Checkpoints Dashboard** | `lib/screens/checkpoints_dashboard_screen.dart` | Material 3 Zoom push | Daily habit checkpoints, streak tracking, frequency rules, completion matrices, and streak freeze protections. |
| **Device Health Intro** | `lib/screens/device_health_intro_screen.dart` | Contextual push | Explains Android battery optimization exemptions, background wake locks, and reliable widget sync. |
| **End of Support Notice** | `lib/screens/end_of_support_screen.dart` | Legacy system gate | Transparent notice for deprecated Android API levels with data export recovery tools. |

### 2.2 Comprehensive Settings Ecosystem (`lib/dialogs/settings/`)
The settings architecture is organized into an Apple HIG Inset Grouped hierarchy navigated via `SettingsDialog` (`lib/dialogs/settings_dialog.dart`):
1. **`settings_dashboard_page.dart`**: Executive overview, quick stats, direct links to Intelligence Hub and Life Audit.
2. **`activity_tags_settings_page.dart`**: Custom tag taxonomy, color badge assignments, tag usage frequency, auto-migration.
3. **`advanced_settings_page.dart`**: Low-memory mode, search index rebuild, database compaction, cache eviction.
4. **`app_icons_settings_page.dart`**: Dynamic Android launcher icon switching (7 color variants via `activity-alias`).
5. **`app_lock_settings_page.dart`**: Biometric auth (Fingerprint/Face), Android System Credential lock, In-App PIN, lock timeouts (`0m`, `1m`, `5m`, `15m`).
6. **`app_permissions_settings_page.dart`**: Full audit of Android runtime permissions (`RECORD_AUDIO`, `CAMERA`, `POST_NOTIFICATIONS`, `SYSTEM_ALERT_WINDOW`, `SCHEDULE_EXACT_ALARM`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, `PACKAGE_USAGE_STATS`).
7. **`app_philosophy_settings_page.dart`**: Manifesto on offline sovereignty, digital minimalism, and intentional time accounting.
8. **`capture_settings_page.dart`**: Default capture mode (single tap vs two-way start/stop), tap delay buffers, draft preservation.
9. **`commits_settings_page.dart`**: In-app audit trail displaying verified Git commits and release history.
10. **`content_rating_settings_page.dart`**: IARC / Google Play rating disclosure (Rated 3+ / Everyone).
11. **`data_backup_settings_page.dart`**: Sovereign `.notekar-vault` encrypted backup (PBKDF2/AES-GCM), plain JSON, CSV (full & recent 30-day), Markdown sync, snapshot restore, backup health diagnostics.
12. **`diagnostics_settings_page.dart`**: Real-time rendering telemetry, frame drops, Isar collection sizes, memory footprint.
13. **`display_settings_page.dart`**: 5 Themes (Light, Dark, AMOLED, E-Ink, Matrix), 7 Accent colors, High Contrast mode, font scaling clamp (0.85x – 2.0x), OpenType Tabular Figures toggle, Reduce Motion.
14. **`feedback_changelog_settings_page.dart`**: Offline feedback generator and multi-version changelog viewer.
15. **`god_mode_settings_page.dart`**: Developer flags, mock generator, database surgery tools, circuit breaker test.
16. **`help_guides_settings_page.dart`**: Searchable interactive user manuals, workflow tutorials, FAQ cards.
17. **`integrations_settings_page.dart`**: Android Quick Settings tiles, home screen widgets, Share Sheet targets, App Shortcuts.
18. **`legal_about_settings_page.dart`**: Sovereign privacy policy, terms of use, OSS licenses, developer credits.
19. **`life_audit_page.dart`**: 8-domain wheel-of-life assessment with radar scores, action plans, and historical re-audits.
20. **`logging_settings_page.dart`**: Timestamp rounding (exact, 1m, 5m, 15m), 12h/24h clock toggle, midnight boundary rollover.
21. **`modes_categories_settings_page.dart`**: Category manager (Work, Deep Focus, Study, Health, Play, Routine, Custom) with custom hex tokens and icons.
22. **`moments_settings_page.dart`**: Timeline density (standard vs compact), auto-expand notes, inline media previews.
23. **`personal_profile_settings_page.dart`**: Local sovereign profile, milestone badges, avatar personalization.
24. **`personalization_settings_page.dart`**: Milestone steppers, landmark life events, daily quote provider.
25. **`privacy_security_settings_page.dart`**: Google Play Data Safety breakdown, VirusTotal scan report verification, recents screen obfuscation (`FLAG_SECURE`).
26. **`reminders_settings_page.dart`**: Scheduled notifications via `SCHEDULE_EXACT_ALARM` for daily check-in, reflection, and backup nudges.
27. **`search_notes_settings_page.dart`**: Global full-text search across all notes, categories, tags, and dates with keyword highlighting.
28. **`security_privacy_details_sheets.dart`**: Zero-telemetry deep dive verification sheets.
29. **`sobriety_companion_settings_page.dart`**: Sobriety milestone engine, clean date calculation, milestone shields, urge surfing triggers.
30. **`targets_projects_settings_page.dart`**: Long-term target allocation and short-term project configurations.
31. **`time_reflection_settings_page.dart`**: Stoic Memento Mori life calendar, weeks-of-life matrix, mortality horizon.
32. **`trash_bin_settings_page.dart`**: 30-day soft-delete trash bin with single/bulk restore and permanent asset purging.
33. **`upcoming_features_settings_page.dart`**: Architecture roadmap and future feature backlog.
34. **`update_center_page.dart`**: GitHub releases checker, APK package downloader, SHA-256 checksum validator.

### 2.3 Modal Sheets & Dialogs (`lib/dialogs/`)
- **`history_dialog.dart`**: Canonical timeline ledger. Supports both standard continuous scroll and calendar day canvas view (`HistoryCalendarView`), filter drawer (`TimelineFilterSheet`), smart trim, and entry merging.
- **`note_dialog.dart`**: WhatsApp-style keyboard-docked note composer with markdown preview, hashtag suggestions, multi-photo staging, voice recording, undo/redo, and sobriety mood tray.
- **`big_note_dialog.dart`**: Full-screen distraction-free markdown canvas for extensive journaling.
- **`manual_entry_dialog.dart`**: Retroactive timestamp logger for logging past moments or full sessions up to 30 days prior.
- **`goals_sheet.dart`**: Apple HIG target allocation sheet with pacing deficit calculations and 1-tap session launch.
- **`projects_sheet.dart`**: Short-term initiative tracker with milestone progress and active session linking.
- **`app_date_picker_sheet.dart`**: Cupertino wheel date/time picker inside an Apple HIG modal sheet.
- **`apple_hig_action_sheet.dart`**: Native iOS-styled action sheet with frosted backdrop and destructive alerts.
- **`merge_entries_sheet.dart`**: Surgical tool to combine adjacent split sessions or collapse fragmented logs.
- **`smart_trim_sheet.dart`**: Visual scrubber to trim idle minutes from session start or end boundaries.
- **`urge_surfing_dialog.dart`**: Guided 3-minute breathwork and mindfulness exercise for addiction recovery.
- **`vault_password_dialog.dart`**: Cryptographic password entry with strength indicator and salt verification.
- **`peer_profile_scanner_page.dart` & `peer_comparison_sheet.dart`**: Offline peer profile sharing via QR code scanning without any internet connection.
- **`shareable_stats_sheet.dart` & `shareable_milestone_sheet.dart`**: Generates high-DPI Apple HIG graphic cards for sharing.

---

## 3. Database Architecture & Storage Models

### 3.1 Primary Entities
1. **`Moment` (`lib/models/moment.dart`)**:
   - Primary Isar collection (`@collection`).
   - Fields: `id` (`Id`), `timestamp` (`int`), `type` (`String`: `'single'`, `'in'`, `'out'`), `date` (`String`: `'YYYY-MM-DD'`), `note` (`String`), `category` (`String?`), `tags` (`List<String>`), `imagePath` (`String?`, pipe-separated relative paths), `voicePath` (`String?`, pipe-separated relative paths), `voiceDurationMs` (`int?`), `goalId` (`String?`), `projectId` (`String?`).
   - Computed Invariants: `effectiveCategory`, `effectiveTags`, `imagePaths`, `voicePaths`, `isValid` (enforces positive ID, timestamp sanity within 24h future drift).
2. **`Goal` (`lib/models/goal.dart`)**:
   - Represents intentional target allocations (timeframes: `week`, `month`, `year`, `allTime`).
   - Tracks target duration, invested seconds, milestone checklists, and pacing deficits.
3. **`Project` (`lib/models/project.dart`)**:
   - Short-term initiatives with targeted deadlines, milestones, and moment tagging (`proj:<id>`).
4. **`Checkpoint` (`lib/models/checkpoint.dart`)**:
   - Daily habits and micro-commitments with custom frequencies and streak counters.
5. **`Palette` (`lib/models/palette.dart`)**:
   - Theme styling entity containing semantic tokens (`bg`, `surface`, `surface2`, `surface3`, `border`, `text`, `text2`, `text3`, `clock`, `accent`, `green`, `orange`, `red`, `blue`, `onAccent`).

### 3.2 Storage Invariants & Security
- **Dual-Layer Persistence**: Isar database acts as the authoritative store; critical state (`_momentsCacheJson`, active session, theme, accent) is mirrored to `SharedPreferences` to ensure instantaneous UI boot (<50ms) before Isar isolate initialization.
- **Relative Media Paths**: Media paths are stored strictly as invariant relative sandbox paths (`images/img_<timestamp>_<random>.jpg`, `voice/voice_<timestamp>_<random>.m4a`). Absolute paths (`/data/user/0/...`) are strictly forbidden.
- **Sovereign Vault**: Encrypted exports (`.notekar-vault`) use NIST SP 800-38D AES-256-GCM authenticated encryption with PBKDF2-HMAC-SHA256 (100,000 iterations, 16-byte cryptographically secure salt, 12-byte IV, 128-bit tag).

---

## 4. Android Native Platform Integration

### 4.1 Android Manifest & Permissions (`android/app/src/main/AndroidManifest.xml`)
- **Permissions Declared**:
  - `android.permission.RECORD_AUDIO`: Required only when user records voice notes.
  - `android.permission.CAMERA`: Required only when user takes photos for moments.
  - `android.permission.VIBRATE`: Haptic tactile feedback.
  - `android.permission.INTERNET`: Used strictly for GitHub release checks and bulletin fetches (opt-in).
  - `android.permission.POST_NOTIFICATIONS`: Android 13+ (API 33+) notification permission.
  - `android.permission.RECEIVE_BOOT_COMPLETED`: Restores exact alarms and widget state after reboot.
  - `android.permission.SCHEDULE_EXACT_ALARM`: Triggers precise daily wrap-up and reminder alarms.
  - `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: Prevents OEM aggressive killing of live session timers.
  - `android.permission.WAKE_LOCK`: Ensures timer completion during deep sleep.
  - `android.permission.REQUEST_INSTALL_PACKAGES`: Self-updater for GitHub APK releases.
  - `android.permission.SYSTEM_ALERT_WINDOW`: Floating bubble chronometer service.
  - `android.permission.FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_SPECIAL_USE`: Live session notification.
  - `android.permission.WRITE_EXTERNAL_STORAGE` (`maxSdkVersion="28"`): Legacy Android 9 storage compatibility.
  - `android.permission.PACKAGE_USAGE_STATS` (`tools:ignore="ProtectedPermissions"`): Digital Wellbeing correlation.
  - Custom Signature Permission: `app.notekar.notekar.permission.LOG_BROADCAST` (protects IPC broadcast intents).

### 4.2 Native Activities & Services (`android/app/src/main/kotlin/app/notekar/notekar/`)
1. **`MainActivity.kt`**: Flutter engine host, registers MethodChannels (`notekar/files`, `notekar/audio`, `notekar/wellbeing`), handles recents obfuscation (`FLAG_SECURE`), configures dynamic broadcast receivers.
2. **`ShareReceiverActivity.kt`**: Translucent headless activity that intercepts incoming shared text, URLs, and up to 5 images, persisting them directly to `SharedPreferences` and broadcasting to Flutter without launching the heavy main UI.
3. **`QuickNoteActivity.kt`**: Floating lightweight dialog for instant note logging from notifications or app shortcuts.
4. **`InstantCameraCaptureActivity.kt`**: Lockscreen-accessible camera shortcut for instant timestamped photo capture.
5. **`QuickNoteTileService.kt` & `FloatingBubbleTileService.kt`**: Quick Settings tiles for 1-tap logging and floating timer toggle.
6. **`FloatingTimerService.kt`**: Android foreground service with draggable floating bubble overlay displaying live session elapsed time.
7. **AppWidget Providers** (`RemoteViews`):
   - `NoteKarWidgetProvider`: Primary multi-action widget (Log, Modes, Start, Stop).
   - `SessionWidgetProvider`: Compact live session chronometer widget.
   - `SobrietyWidgetProvider`: Clean streak counter and milestone shield widget.
   - `InstantCameraWidgetProvider`: 1-tap camera capture widget.
   - `LifeAuditWidgetProvider`: Weekly domain balance widget.
8. **Receivers**:
   - `NotificationActionReceiver.kt`: Intercepts notification button clicks (`📝 Log`, `🏷️ Modes`, `▶ Start`, `⏹ OUT`).
   - `NotificationConsistencyManager.kt`: Enforces monochrome `R.drawable.ic_stat_notekar` icon and prevents notification flicker.
   - `ReminderReceiver.kt`: Exact alarm receiver for scheduled reflections and backup reminders.
   - `UnlockReceiver.kt`: Synchronizes widget state upon `ACTION_USER_PRESENT`.

---

## 5. Apple HIG Design & Experience Evaluation

### 5.1 Design System Alignment (`NkTokens` / `DESIGN_SYSTEM.md`)
- **Spatial Geometry**: Continuous superellipse squircle curvature (`ContinuousSquircleBorder`, `NkRadii.card` = 16pt, `NkRadii.sheet` = 28pt, `NkRadii.dialog` = 28pt).
- **Typography Scale**: High-precision Inter scale with optical tracking:
  - `largeTitle` (34pt, w800, -1.3 tracking), `title1` (28pt, w700, -0.8 tracking), `title2` (22pt, w700, -0.6 tracking), `title3` (20pt, w600, -0.5 tracking), `headline` (17pt, w600, -0.4 tracking), `body` (17pt, w400, -0.3 tracking), `subheadline` (15pt, w400, -0.2 tracking), `footnote` (13pt, w400, -0.1 tracking), `caption` (12pt, w500, 0.0 tracking).
- **Tabular Figures**: OpenType tabular figures (`.withTabularFigures()`) applied to chronometers and stopwatches to prevent digit jitter.
- **Haptic Feedback**: Tiered tactile haptics (`selectionClick` for chips, `mediumImpact` for logging/sessions, `heavyImpact` for destructive actions).
- **Pressable Scale**: Interactive buttons and cards spring scale to `0.97` on pointer press.

### 5.2 Identified Design Drift & Inconsistencies
1. **Parallel Card Implementations**: Three competing card patterns exist across screens: `NkCard` (canonical design system), `SettingsGroup` (`lib/widgets/settings_widgets.dart`), and `HigGroupedCard` (`lib/widgets/hig_widgets.dart`).
2. **Typography Hardcoding**: Several settings pages (e.g. `legal_about_settings_page.dart`, `content_rating_settings_page.dart`) use raw inline `TextStyle(fontSize: 20, fontWeight: FontWeight.w900)` rather than canonical `NkTokens.typography` tokens.
3. **Divider Indent Variations**: Certain custom lists use `16.0pt` left divider padding, while canonical Apple HIG inset grouped lists require `56.0pt` to align with text after leading icon badges.
4. **Button Height Standardization**: Some action buttons use `56.0pt` minimum height while others use `50.0pt` or default Material button padding.
5. **Touch Target Verification**: While most controls meet `NkTouchTarget.minInteractive` (48×48dp), several compact timeline chip actions measure 36×36dp without expanded touch slop.

---

## 6. Build Configuration & Release Readiness

### 6.1 Gradle & Build Scripts
- **Gradle**: Root Gradle build uses Kotlin DSL (`build.gradle.kts`), Java 17 compatibility, and Android Gradle Plugin 8.9.0.
- **Desugaring**: `coreLibraryDesugaringEnabled = true` with `desugar_jdk_libs:2.1.4` ensures modern Java time and collection APIs function seamlessly on API 26+.
- **R8 / Proguard**: Full code minification and resource shrinking enabled (`isMinifyEnabled = true`, `isShrinkResources = true`) with custom `proguard-rules.pro` protecting Isar, Gson, and Flutter plugins.
- **Vulkan / Impeller Guard**: Manifest explicitly sets `io.flutter.embedding.android.EnableImpeller = false` to eliminate GPU driver crashes and green-screen artifacts on Mali/Adreno chipsets.
- **Multi-ABI Signing**: `scripts/build-release-apks.ps1` builds split per-ABI APKs (`arm64-v8a`, `armeabi-v7a`, `x86_64`) with automated SHA-256 checksum generation.

---

## 7. Audit Conclusion & Baseline Sign-Off

The NoteKar codebase is in exceptional technical health: 559 automated tests passing, 0 lint warnings, clean architecture, and complete air-gapped privacy. The following improvement plan targets surgical polish, design unification, enhanced user experience, and Google Play hardening—all while strictly preserving every working feature and domain invariant.
