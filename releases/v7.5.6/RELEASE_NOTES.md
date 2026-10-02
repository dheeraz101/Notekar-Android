## NoteKar v7.5.6: Sovereign Goals, Activity Tags & Sensory Precision

Signed production/beta release built automatically from the `dev` branch.

### 🌟 What's New

- **Flagship Apple HIG Goals Engine & Session Attribution**:
  - Redesigned goal cards into full-width cards with category accent borders, enlarged 38x38 tactile hit targets, and live active session pulse with 1-tap stop.
  - Added daily investment pacing indicators and flexible `GoalTimeframe.custom` deadline date picker.
  - Timeline session attribution pills: sessions recorded under active categories display goal badges in the Life Ledger.
  - Enforced strict 9-character crisp goal title limit across creation, storage, and rendering.
  - Dynamic Two-Way mode center pill swipe gesture and bounce animation to switch active goals on the fly.
  - Automatic note composer prompt on `Log OUT` so reflections can be captured seamlessly.
- **Activity Quick-Tags Engine & Tagged Notes**:
  - Introduced 15 research-backed daily human activity tags with native Cupertino glyphs.
  - Dedicated **Settings → Activity Tags** management page.
  - Raw `#hashtags` in note bodies are automatically parsed into elegant Apple HIG glyph pills in timeline view mode.
  - Moved `+ Tag` shortcut to the front of NoteDialog carousel for 1-tap categorization.
- **Motivation Quick-Logging & Widget Previews**:
  - Interactive quick-logging dialog in `QuickNoteActivity` with activity tag chips and note input.
  - Configurable setting in **Settings → Logging** (`notif_log_action`) to toggle between instant popup dialog and silent logging.
  - Upgraded launcher widget picker previews to photorealistic, antialiased assets (`drawable-nodpi`) showing authentic Bebas Neue numerals and progress rings.

### ⚡ Improvements

- **Distraction-Free Canvas & Launch Polish**:
  - Unified header rhythm card: merged Today's Momentum card and circadian bar into a single minimal card inside `DynamicHeaderCapsule`.
  - Removed redundant floating clock complication from home canvas.
  - Eliminated startup personalization dialog popup for an instant, distraction-free app entry.
  - Eliminated duplicate splash screen on Android 12+ by setting `windowSplashScreenAnimatedIcon` to transparent.
  - Replaced Android `QuickNoteActivity` window theme with `Theme.NoteKar.TranslucentDialog` to eliminate square background clipping on older Android versions.

### 🛠️ Bug Fixes

- **Platform Reliability & AOT Build Optimizations**:
  - Resolved Kotlin runtime exception in `MainActivity.kt` when querying `FlutterSharedPreferences` for notification logging actions.
  - Replaced dynamic `IconData` constructors with compile-time constant `CupertinoIcons` lookup tables in `ActivityTag` and settings, enabling Flutter Ahead-of-Time (AOT) tree-shaking and reducing binary footprint.
  - Fixed single-mode goal session start where the initial tap failed to trigger a session.
  - All 236 automated unit and sensory tests passing with 100% pass rate and zero lints.

### 🛡️ Build Integrity

- **Version**: `7.5.6`
- **Build Tag**: `26BR1002` (versionCode `26100201`)
- **Automated Tests**: All 236 unit & widget tests passing (0 failures, 0 lints)
- **Architecture**: 100% Private, Zero Telemetry, Offline-First Hive NoSQL
