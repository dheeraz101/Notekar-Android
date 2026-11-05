# NoteKar 500+ Micro-Improvements Inventory: Part 5
## Focus Area: Settings Suite & 35 Subpages, Zero-Knowledge Vault Encryption, App Lock, Android Native Integration, Quick Settings Tiles, Widgets & Performance Architecture
### Items: IMP-401 to IMP-505

---

### IMP-401: Zero-Knowledge Vault PBKDF2 Iteration Auto-Scaling
- **Category:** Security / Architecture
- **Current behaviour:** In `lib/services/vault_encryption_service.dart:24`, `defaultPbkdf2Iterations` is hardcoded to `10,000`. OWASP currently recommends at least 600,000 iterations for SHA-256 password hashing to resist modern GPU-accelerated brute force.
- **Proposed improvement:** Upgrade default PBKDF2 iterations to `100,000` with an adaptive benchmark test that auto-scales iterations so key derivation takes approximately 350ms on the user's specific CPU.
- **User benefit:** Military-grade sovereign encryption protecting `.notekar-vault` backups against offline supercomputer brute-forcing.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/services/vault_encryption_service.dart:24`
- **Verification:** Export encrypted vault; verify metadata JSON headers confirm key derivation uses calibrated 100k+ iterations.

---

### IMP-402: In-App PIN Setup Overlay Success Shake & Biometric Grace Period
- **Category:** Security / UX
- **Current behaviour:** In `lib/dialogs/settings/app_lock_settings_page.dart:97-105`, selecting "Immediately" for lock delay locks the app instantly when switching to a 2-factor authenticator app for 5 seconds.
- **Proposed improvement:** Provide an intelligent 30-second `Grace Window for 2FA` setting that allows rapid app-switching without re-triggering biometric prompts.
- **User benefit:** Frictionless 2FA code copying while keeping sovereign data completely secure from unauthorized physical access.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/app_lock_settings_page.dart:99`
- **Verification:** Copy 2FA code in external app, return within 15 seconds; confirm app remains unlocked seamlessly.

---

### IMP-403: Quick Note Tile Service Dark / Light Theme Android QS Icon Sync
- **Category:** Android System Integration / Visual Polish
- **Current behaviour:** In `QuickNoteTileService.kt:15-30`, the Quick Settings tile icon is static `@drawable/ic_stat_notekar`. In Android 14/15 themed icon palettes, it lacks Monet dynamic color harmonisation.
- **Proposed improvement:** Provide adaptive vector drawable with monochrome layer for Android Material You dynamic Quick Settings theming.
- **User benefit:** System-level aesthetic harmony on modern Android 13/14/15 status bars and Quick Settings panels.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `android/app/src/main/res/drawable/ic_stat_notekar.xml`
- **Verification:** Toggle Material You dynamic color theme on Android 14; verify Quick Note tile adopts the active system accent color.

---

### IMP-404: Floating Timer Service Screen Edge Auto-Magnet Snap
- **Category:** Android System Integration / Ergonomics
- **Current behaviour:** In `FloatingTimerService.kt:42-56`, dragging the floating bubble drops it at the exact finger coordinates, occasionally leaving it floating awkwardly in the middle of active reading content.
- **Proposed improvement:** On `ACTION_UP`, animate the bubble with `OvershootInterpolator` snapping smoothly to the nearest left or right screen edge (within 8dp margin).
- **User benefit:** Out of the way: never obstructs buttons or text on other apps while timing in the background.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:45`
- **Verification:** Drag floating bubble to screen center and release; observe it glide smoothly to the right screen edge and dock.

---

### IMP-405: NoteKar App Widget High-Contrast Typography Rendering
- **Category:** Android System Integration / Accessibility
- **Current behaviour:** In `NoteKarWidgetProvider.kt:80-120`, RemoteViews text colors use hardcoded semi-transparent white `#CCFFFFFF`. On light wallpaper backgrounds without launcher scrims, text legibility is degraded.
- **Proposed improvement:** Use dynamic theme-aware `notekar_widget_background.xml` with automatic ambient luminance detection and drop shadow backing on widget numerals.
- **User benefit:** 100% crisp legibility across all wallpaper colors and styles.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/res/layout/notekar_widget_card.xml`
- **Verification:** Place NoteKar widget over a stark white wallpaper; confirm widget text and card outline remain razor-sharp.

---

### IMP-406: Update Center Page APK SHA-256 Checksum Live Comparison Tooltip
- **Category:** Security / Transparency
- **Current behaviour:** In `lib/dialogs/settings/update_center_page.dart:62`, the verification status displays "verified" as text, but doesn't show the mathematical SHA-256 hash string for verification against GitHub releases.
- **Proposed improvement:** Display the full 64-character SHA-256 hex string in a monospaced tap-to-copy card: `"SHA256: 7f8a3b... [Copy Hash]"`.
- **User benefit:** Absolute cryptographic transparency empowering security-conscious users to independently verify release binaries.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/update_center_page.dart:64`
- **Verification:** Download update APK in Update Center; observe full SHA-256 checksum displayed with 1-tap copy action.

---

### IMP-407: Diagnostics Settings Network Monitor Masking of Sensitive Tokens
- **Category:** Security / Privacy
- **Current behaviour:** In `lib/dialogs/settings/diagnostics_settings_page.dart:38`, `NetworkLogEntry` logs raw query strings and headers during update checks. If an authorization token was ever sent, it could be visible in the log viewer.
- **Proposed improvement:** Automatically sanitize and mask tokens in `NetworkLogger`: replace tokens, passwords, and sensitive keys with `[REDACTED]`.
- **User benefit:** Zero accidental leakage of private tokens or credentials when exporting diagnostic reports.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/network_logger.dart:45`
- **Verification:** Inspect network logs in Diagnostics; verify any header containing 'auth' or 'token' is masked with `[REDACTED]`.

---

### IMP-408: App Permissions Health Score Overall Visual Gauge
- **Category:** Visual Polish / Privacy
- **Current behaviour:** In `lib/dialogs/settings/app_permissions_settings_page.dart:98`, `_grantedCount` shows `"5 of 7 permissions granted"`.
- **Proposed improvement:** Render an Apple-style circular privacy gauge showing permission status with a green badge for minimal necessary access.
- **User benefit:** Clear, reassuring confirmation of the app's minimal, privacy-first permission footprint.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/app_permissions_settings_page.dart:100`
- **Verification:** View Permissions Settings; observe sleek privacy shield gauge summarizing active hardware access.

---

### IMP-409: Data Backup Auto-Backup Reminder Frequency Customization
- **Category:** Settings / Data Safety
- **Current behaviour:** In `lib/dialogs/settings/data_backup_settings_page.dart:43`, reminder options are fixed (e.g. 7, 14, 30 days).
- **Proposed improvement:** Add a `Every 3 Days` option for high-volume daily professionals, and `After Every 50 Moments Logged` event-based trigger.
- **User benefit:** Proactive backup prompts calibrated to the actual volume of data written.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/data_backup_settings_page.dart:44`
- **Verification:** Select 'After 50 moments'; log 50 moments; observe gentle notification prompting quick sovereign backup.

---

### IMP-410: Settings Dialog Search Breadcrumb Path Highlight
- **Category:** Search Intelligence / Navigation
- **Current behaviour:** In `lib/dialogs/settings/settings_dialog_search.dart:45-80`, search results show setting title and parent section (e.g. `Show Seconds - Display`), but don't show the exact breadcrumb hierarchy.
- **Proposed improvement:** Render clean navigational breadcrumb pills: `Settings › Display & Visuals › Time Format › Show Seconds`.
- **User benefit:** Instant mental map of where any setting resides in the overall settings taxonomy.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/settings_dialog_search.dart:60`
- **Verification:** Search for "PIN"; observe clear breadcrumb path `Settings › App Lock & Privacy › In-App PIN`.

---

### IMP-411: Obfuscate in Recents Android Task Description Snapshot Shield
- **Category:** Privacy / Security
- **Current behaviour:** In `MainActivity.kt:58-61`, `FLAG_SECURE` is applied when `obfuscate_in_recents` is enabled. However, this also blocks users from taking personal screenshots of their own notes inside the app.
- **Proposed improvement:** Apply `FLAG_SECURE` dynamically in `onPause()` / `onStop()` when moving to background, and clear it in `onResume()`.
- **User benefit:** Recents card is 100% blanked in the Android multitasking carousel, while the user retains full freedom to take screenshots while using the app.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:70`
- **Verification:** Enable Obfuscate in Recents; open app, take screenshot (succeeds); open Android multitasking recents; verify thumbnail is completely blanked.

---

### IMP-412: Modes & Categories Settings Category Color Contrast Auto-Validation
- **Category:** Accessibility / Visual Polish
- **Current behaviour:** In `lib/dialogs/settings/modes_categories_settings_page.dart:180-220`, users can assign custom hex colors to categories. If a user enters `#F5F5F5` (near-white) in Light theme, text becomes completely invisible.
- **Proposed improvement:** Validate custom category colors against WCAG AA 3:1 contrast ratio against the background; auto-adjust lightness by ±15% if contrast is insufficient.
- **User benefit:** Custom category tags and badges remain effortlessly legible regardless of color choice.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/modes_categories_settings_page.dart:195`
- **Verification:** Set category color to bright pale yellow; view category in Light theme; confirm intelligent luminance adjustment preserves crisp contrast.

---

### IMP-413: Activity Tags Usage Frequency Count Badge in Settings
- **Category:** Organization / UX
- **Current behaviour:** In `lib/dialogs/settings/activity_tags_settings_page.dart:80-120`, tags are listed alphabetically without usage metrics.
- **Proposed improvement:** Display the lifetime usage count badge beside each tag: `#deepwork (142 moments)`.
- **User benefit:** Easily spot dead or single-use typo tags (e.g. `#wrk (1)`) for quick consolidation or deletion.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/activity_tags_settings_page.dart:95`
- **Verification:** Open Activity Tags settings; see exact usage counts beside each tag pill.

---

### IMP-414: Diagnostics Developer Quest 7-Tap Haptic Escalation
- **Category:** Delight / Micro-Interaction
- **Current behaviour:** In `lib/dialogs/settings/diagnostics_settings_page.dart:79-93`, tapping the build number 7 times plays light clicks on taps 4-6, then heavy impact on tap 7.
- **Proposed improvement:** Implement a rising musical pitch sequence (ascending acoustic micro-ticks) accompanying the haptic clicks from tap 1 to 7.
- **User benefit:** Classic, joyful Android Easter egg experience that rewards exploratory curiosity.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:84`
- **Verification:** Rapidly tap Build Number 7 times; feel ascending tactile clicks culminating in the God Mode unlock dialog.

---

### IMP-415: Android 14+ Predictive Back Gesture Support on Settings Subpages
- **Category:** Android System Integration / UX
- **Current behaviour:** Navigating back from nested settings subpages (e.g. Display -> Time Format) performs standard pop transitions.
- **Proposed improvement:** Enable `android:enableOnBackInvokedCallback="true"` in AndroidManifest and wrap subpage routes in `PredictiveBackPageTransitionsBuilder`.
- **User benefit:** Smooth, interactive back-swipe peeking that lets users preview the parent settings menu before releasing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings_dialog.dart:120`
- **Verification:** On Android 14+, swipe slowly from left edge in Settings; observe subpage smoothly scale down to reveal parent menu.

---

### IMP-416: Floating Bubble Tile Service Quick Setting Haptic Confirmation
- **Category:** Tactile Feedback
- **Current behaviour:** In `FloatingBubbleTileService.kt:25-40`, tapping the Quick Settings tile starts or stops the floating service silently.
- **Proposed improvement:** Fire a distinct haptic pulse on tile state toggle (`VibrationEffect.createPredefined(EFFECT_CLICK)`).
- **User benefit:** Immediate physical tactile confirmation directly from the Android Quick Settings shade.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingBubbleTileService.kt:32`
- **Verification:** Pull down Quick Settings; tap NoteKar Bubble tile; feel crisp tactile confirmation.

---

### IMP-417: Zero-Knowledge Vault Export Native File Picker Destination
- **Category:** Android System Integration / Sovereignty
- **Current behaviour:** In `lib/dialogs/settings/data_backup_settings_page.dart:180-220`, exporting an encrypted `.notekar-vault` file saves to internal app storage and triggers a generic share intent.
- **Proposed improvement:** Use Android Storage Access Framework (`ACTION_CREATE_DOCUMENT`) to let users choose the exact local folder or external USB drive destination.
- **User benefit:** True sovereign data ownership: save encrypted life ledgers directly to physical SD cards or encrypted hardware drives.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:380`
- **Verification:** Export vault backup; select 'Save to Files'; pick external USB drive; verify file writes directly to USB.

---

### IMP-418: Legal & About Page Sovereign Open-Source License Viewer
- **Category:** Compliance / Polish
- **Current behaviour:** In `lib/dialogs/settings/legal_about_settings_page.dart:60-90`, licenses are shown as a plain text string that can stutter when scrolling on low-end hardware.
- **Proposed improvement:** Format open-source licenses using a virtualized `ListView.builder` with clean package badges and individual copy buttons.
- **User benefit:** Professional, scannable legal transparency complying fully with MIT and Apache open-source obligations.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/legal_about_settings_page.dart:75`
- **Verification:** Open Open Source Licenses in About; observe buttery smooth 60fps scrolling through all dependency credits.

---

### IMP-419: Trash Bin Auto-Purge 30-Day Expiration Policy Notice
- **Category:** Data Safety / Clarity
- **Current behaviour:** In `lib/dialogs/settings/trash_bin_settings_page.dart:40-65`, deleted moments reside in trash indefinitely until manually cleared.
- **Proposed improvement:** Add an optional setting: `Auto-Purge Trash After 30 Days` with a clear explanation badge: `"Moments in trash will be permanently pruned after 30 days"`.
- **User benefit:** Automatic storage maintenance keeping local database size lean and performant.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/trash_bin_settings_page.dart:55`
- **Verification:** Enable 30-day auto-purge; verify moments deleted >30 days ago are safely purged during daily maintenance job.

---

### IMP-420: Floating Timer Bubble Chronometer Text Color Dynamic Luminance Contrast
- **Category:** Android System Integration / Visual Polish
- **Current behaviour:** In `FloatingTimerService.kt:54`, `circleTimeText` color defaults to white `#FFFFFF`. If the floating bubble is customized with a light theme, numbers can become unreadable.
- **Proposed improvement:** Calculate background luminance of the floating circle and dynamically set text color to stark black `#000000` when luminance > 0.45.
- **User benefit:** Floating chronometer numbers remain razor-sharp and legible across all custom bubble theme colors.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:55`
- **Verification:** Set floating bubble color to pastel yellow; observe timer digits automatically render in high-contrast solid black.

---

### IMP-421: Process Text Activity Instant Silent Note Snapping
- **Category:** Android System Integration / Convenience
- **Current behaviour:** Selecting text in a web browser and tapping "Log in NoteKar" via `ProcessTextActivity.kt:15-35` opens the full NoteKar home screen, disrupting the user's reading flow.
- **Proposed improvement:** Log the selected snippet directly to Isar database in the background and show an instant Android Toast: `"Logged to NoteKar ✓"`, leaving the user in their browser.
- **User benefit:** Frictionless 1-second capture of web research snippets without being ripped out of the reading context.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/ProcessTextActivity.kt:25`
- **Verification:** Highlight text in Chrome; tap 'Log in NoteKar'; see instant toast confirmation while remaining inside Chrome.

---

### IMP-422: App Icon Switcher Confirmation Prompt Explaining Launcher Delay
- **Category:** Guidance / UX
- **Current behaviour:** On some Android launchers (Nova, Niagara, Samsung OneUI), changing launcher icon aliases can take 5-10 seconds to refresh on the home screen. Users think the feature is broken.
- **Proposed improvement:** Show a brief toast notification after icon selection: `"Icon updated. Your home screen launcher may take a few seconds to refresh."`.
- **User benefit:** Eliminates support confusion regarding Android launcher cache latency.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/app_icons_settings_page.dart:130`
- **Verification:** Switch app icon style; confirm reassuring toast message explains launcher cache refresh behavior.

---

### IMP-423: Circuit Breaker Service Database Auto-Quarantine Health Report
- **Category:** Reliability / Architecture
- **Current behaviour:** In `lib/services/circuit_breaker_service.dart:25-50`, if native Isar encounters a crash loop, it trips the circuit breaker silently.
- **Proposed improvement:** Display an informative Sovereign Health Card on next launch explaining that the database was quarantined safely and automatically recovered from the last rolling snapshot.
- **User benefit:** User transparency and deep peace of mind knowing that zero data was lost during unexpected OS storage corruptions.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/services/circuit_breaker_service.dart:35`
- **Verification:** Trigger mock database open exception; restart app; observe clear Sovereign Health recovery notification.

---

### IMP-424: Data Backup Settings Snapshot Auto-Rolling Frequency
- **Category:** Reliability / Data Safety
- **Current behaviour:** In `lib/utils/moment_repository.dart:24`, auto rolling snapshot runs on midnight maintenance only.
- **Proposed improvement:** Create a rolling local snapshot after every 25 moments logged (`_autoRollingSnapshot`), keeping the last 3 rolling snapshots in local cache.
- **User benefit:** Near-zero recovery point objective (RPO): maximum 25 moments vulnerable in catastrophic hardware loss scenarios.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/moment_repository.dart:185`
- **Verification:** Log 25 moments; check file system; verify `notekar.auto_rolling_snapshot` updates with current timestamp.

---

### IMP-425: Logging Settings Export App Logs Anonymized File
- **Category:** Privacy / Debuggability
- **Current behaviour:** In `lib/dialogs/settings/logging_settings_page.dart:60-90`, copying application logs copies raw debug text.
- **Proposed improvement:** Provide an "Export Anonymized Diagnostic Package" button that automatically strips personal notes, category labels, and device serial identifiers.
- **User benefit:** Completely safe bug reporting without exposing personal life ledger content to developers.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/settings/logging_settings_page.dart:75`
- **Verification:** Export diagnostic logs; inspect file; confirm note texts are replaced with `[NOTE_LENGTH_34]`.

---

### IMP-426: Reminders Settings Bedtime Wind-Down Dynamic Calculation
- **Category:** Health / Automation
- **Current behaviour:** In `lib/dialogs/settings/reminders_settings_page.dart:50-80`, reminders use static hours (e.g. 22:00).
- **Proposed improvement:** Calculate dynamic bedtime reminder based on target waking time: `"8h sleep target: Wind down at 22:15 to wake up refreshed at 06:15"`.
- **User benefit:** Chronobiologically aligned bedtime alerts that adapt to personal wake-up schedules.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/reminders_settings_page.dart:65`
- **Verification:** Set 06:00 wake target and 8h sleep goal; confirm wind-down reminder automatically recommends 22:00 alert.

---

### IMP-427: God Mode Easter Egg Sound Effect Toggle
- **Category:** Delight / Audio
- **Current behaviour:** Unlocking God Mode plays a celebratory sound, which cannot be disabled if sound effects are enabled globally.
- **Proposed improvement:** Respect system silent mode and provide a toggle for God Mode retro 8-bit sound effects.
- **User benefit:** Respects quiet environments while preserving nostalgic retro computing charm.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/god_mode_settings_page.dart:45`
- **Verification:** Unlock God Mode with phone on silent; verify no loud sound plays.

---

### IMP-428: Feedback Changelog Settings Markdown Formatted Release Notes
- **Category:** Visual Polish
- **Current behaviour:** In `lib/dialogs/settings/feedback_changelog_settings_page.dart:40-70`, changelog text is displayed as plain unformatted lines.
- **Proposed improvement:** Render release notes using `MarkdownText` with distinct pill badges for `[NEW]`, `[POLISH]`, `[FIX]`, and `[SECURITY]`.
- **User benefit:** Scannable, exciting product evolution updates that celebrate continuous improvements.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/feedback_changelog_settings_page.dart:55`
- **Verification:** Open Changelog in settings; observe styled markdown release notes with colorful category badges.

---

### IMP-429: Session Widget Provider Android Home Screen Chronometer Refresh
- **Category:** Android System Integration / Performance
- **Current behaviour:** In `SessionWidgetProvider.kt:40-60`, the home screen widget chronometer refreshes on every tick, which on some budget Android devices can cause widget process wakeups.
- **Proposed improvement:** Leverage Android `Chronometer` RemoteView (`setBase`, `start`) to delegate time progression completely to Android SystemUI without waking the app process.
- **User benefit:** 0% background battery drain from home screen timer widgets.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/SessionWidgetProvider.kt:45`
- **Verification:** Add Session widget to home screen; inspect battery historian logs; confirm zero process wakeups from widget.

---

### IMP-430: Display Settings OLED Deep Black vs True Charcoal Dark Mode
- **Category:** Personalization / Visual Polish
- **Current behaviour:** In `lib/dialogs/settings/display_settings_page.dart:120-160`, themes are limited to 'Dark' (`#1C1C1E`), 'Light', and 'AMOLED' (`#000000`).
- **Proposed improvement:** Introduce a luxury 'Midnight Slate' theme (`#121316`) for users who find pitch black OLED too stark and standard grey dark mode too washed out.
- **User benefit:** High-end, sophisticated aesthetic option inspired by Apple Xcode dark canvas.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/models/palette.dart:140`
- **Verification:** Select 'Midnight Slate' in Display settings; observe elegant deep slate canvas styling.

---

### IMP-431: Share Receiver Activity Multi-Image Import Buffer Progress Bar
- **Category:** Android System Integration / Media
- **Current behaviour:** When sharing 5 high-resolution photos into NoteKar from Android Photos via `ShareReceiverActivity.kt:70-97`, processing is silent.
- **Proposed improvement:** Show a sleek floating pill HUD: `"Importing 3 of 5 photos..."` with a progress indicator.
- **User benefit:** Clear visual confirmation that high-res images are being safely encrypted and sandboxed.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/ShareReceiverActivity.kt:85`
- **Verification:** Share 5 photos into NoteKar; observe clean progress HUD confirm import before closing.

---

### IMP-432: Personal Profile Settings Sovereign Avatar Color Swatch Picker
- **Category:** Personalization
- **Current behaviour:** In `lib/dialogs/settings/personal_profile_settings_page.dart:120-150`, user avatar initials use a randomly assigned color.
- **Proposed improvement:** Allow users to pick their personal avatar initials background color from the 12 sovereign brand swatches.
- **User benefit:** Ownership over personal identity representation in profile and share cards.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/personal_profile_settings_page.dart:135`
- **Verification:** Change profile avatar color to Ruby Red; verify profile header updates immediately.

---

### IMP-433: Advanced Settings Reset Cache Safety Confirmation Shield
- **Category:** Reliability / UX
- **Current behaviour:** Tapping "Clear Image Cache" in Advanced Settings clears cache immediately.
- **Proposed improvement:** Show confirmation dialog noting exact disk space to be reclaimed: `"Clear 48.2 MB of temporary thumbnail cache? [Cancel] [Clear]"`.
- **User benefit:** Prevents accidental deletion of cached thumbnails that would require re-decoding.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/advanced_settings_page.dart:85`
- **Verification:** Tap Clear Cache; verify prompt displays exact MB to be freed before execution.

---

### IMP-434: Floating Timer Service Bottom Dismiss Target Magnification
- **Category:** Android System Integration / Gestures
- **Current behaviour:** In `FloatingTimerService.kt:58-63`, when dragging the bubble over the bottom "✕" dismiss target, the target icon stays static.
- **Proposed improvement:** Scale the dismiss target circle by `1.25x` with a distinct `HapticFeedback.mediumImpact()` when the bubble enters the dismissal hit box.
- **User benefit:** Clear, physical visual and tactile affordance confirming the bubble is ready to be dismissed.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:60`
- **Verification:** Drag floating bubble toward bottom "✕"; feel magnetic haptic tick as dismiss target expands.

---

### IMP-435: Help Guides Search Highlighting
- **Category:** Education / Discoverability
- **Current behaviour:** In `lib/dialogs/settings/help_guides_settings_page.dart:40-80`, browsing user guides requires manual scrolling through topics.
- **Proposed improvement:** Add an instant search bar in Help Guides that matches guide titles and body paragraphs with keyword highlights.
- **User benefit:** Find answers to questions about vault backups or widget setup in 2 seconds.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/help_guides_settings_page.dart:50`
- **Verification:** Type "backup" in Help Guides; verify guide articles explaining vault encryption highlight instantly.

---

### IMP-436: App Lock Biometric Authentication Failure Retry Limit
- **Category:** Security / Privacy
- **Current behaviour:** In `lib/dialogs/privacy_overlay.dart:110-140`, if fingerprint fails 5 times, Android Keyguard locks out, but the UI message can be cryptic.
- **Proposed improvement:** Gracefully transition to custom In-App PIN fallback automatically when biometric hardware lock-out occurs, with clear explanation: `"Too many fingerprint attempts. Please enter your PIN."`.
- **User benefit:** Seamless recovery without app lock-up or confusion when biometric sensors misread moist fingers.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/privacy_overlay.dart:125`
- **Verification:** Fail fingerprint scan 5 times; verify UI smoothly displays PIN keypad with explanatory guidance.

---

### IMP-437: Content Rating Settings Privacy Transparency Badge
- **Category:** Compliance / Trust
- **Current behaviour:** `ContentRatingSettingsPage` shows static rating text.
- **Proposed improvement:** Add a sovereign privacy guarantee seal: `"Zero Analytics • Zero Tracking • 100% Offline Device Isolation"`.
- **User benefit:** Builds deep, unshakable user trust and brand loyalty.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/content_rating_settings_page.dart:65`
- **Verification:** Open Content Rating in settings; observe prominent sovereign offline guarantee seal.

---

### IMP-438: Quick Note Activity Keyboard Focus on Appearance
- **Category:** Android System Integration / UX
- **Current behaviour:** In `QuickNoteActivity.kt:70-100`, launching Quick Note from Quick Settings tile occasionally requires tapping the text input to raise the keyboard.
- **Proposed improvement:** Request window focus and invoke `InputMethodManager.showSoftInput()` immediately on `onWindowFocusChanged(true)`.
- **User benefit:** Zero-delay note taking: tap Quick Settings tile and start typing immediately.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/QuickNoteActivity.kt:85`
- **Verification:** Tap Quick Note tile from locked phone; verify virtual keyboard appears instantly with cursor focused.

---

### IMP-439: Targets & Projects Settings Project Export to JSON Archive
- **Category:** Data Sovereignty / Portability
- **Current behaviour:** In `lib/dialogs/settings/targets_projects_settings_page.dart:50-80`, projects cannot be exported independently of full database backups.
- **Proposed improvement:** Add an "Export Projects Portfolio" button saving all active and archived projects as a structured `notekar_projects.json` file.
- **User benefit:** Granular data export for project management reporting and team status sharing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/targets_projects_settings_page.dart:65`
- **Verification:** Export projects in settings; verify clean JSON file containing all project titles, milestones, and logged hours.

---

### IMP-440: Life Audit Page Dimension Score Weighting Customization
- **Category:** Personalization / Analytics
- **Current behaviour:** In `lib/dialogs/settings/life_audit_page.dart:120-160`, all 6 life dimensions (Career, Health, Relationships, etc.) have equal 1.0x weighting.
- **Proposed improvement:** Allow users to calibrate dimension priorities (e.g. increase Health to 1.5x during fitness focus, decrease Career to 0.8x).
- **User benefit:** Aligns life audit scoring with personal life seasons and priorities.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/life_audit_page.dart:140`
- **Verification:** Adjust Health priority to 1.5x; observe Life Audit composite score calculate using calibrated weightings.

---

### IMP-441: Floating Timer Service Minimal Horizontal Edge Handle Docking
- **Category:** Android System Integration / Visual Polish
- **Current behaviour:** In `FloatingTimerService.kt:45-50`, docked mode collapses into a small line, but the line width is fixed at 12dp, which can be hard to grab with large thumbs.
- **Proposed improvement:** Expand touch hit box to 36dp width while keeping visible graphical bar at 6dp width.
- **User benefit:** Effortless edge-pull un-docking without precise pixel hunting.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:48`
- **Verification:** Dock floating timer to right screen edge; grab comfortably anywhere near edge to slide back out.

---

### IMP-442: Diagnostics Settings Battery Optimization Whitelist Direct Intent
- **Category:** Android System Integration / Reliability
- **Current behaviour:** In `lib/dialogs/settings/diagnostics_settings_page.dart:120`, if battery optimization is enabled, it directs to general battery settings.
- **Proposed improvement:** Launch direct `Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` system intent with `package:app.notekar.notekar`.
- **User benefit:** 1-tap exemption ensuring midnight maintenance, alarms, and widgets run with 100% reliability.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:130`
- **Verification:** Tap Battery Exemption in Diagnostics; confirm native system dialog asks to exempt NoteKar directly in 1 tap.

---

### IMP-443: Personalization Settings Font Scaling Granular 5% Sliders
- **Category:** Accessibility / Typography
- **Current behaviour:** In `lib/dialogs/settings/personalization_settings_page.dart`, text size uses Large Text toggle (on/off).
- **Proposed improvement:** Add a granular typography slider: `85% | 90% | 95% | 100% | 105% | 110% | 115% | 125%`.
- **User benefit:** Precision visual ergonomics matching individual eye prescription requirements.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/personalization_settings_page.dart:110`
- **Verification:** Slide font scale to 110%; verify all app text scales smoothly by exactly 10%.

---

### IMP-444: Instant Camera Widget Direct Shutter-to-Moment Capture
- **Category:** Android System Integration / Multimedia
- **Current behaviour:** In `InstantCameraWidgetProvider.kt:25-50`, tapping the widget launches `InstantCameraCaptureActivity`, but takes 800ms to initialize camera hardware.
- **Proposed improvement:** Pre-bind CameraX service in background; snap photo directly to new moment with zero launch delay.
- **User benefit:** Instant 1-second visual memory capture right from the Android home screen.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/InstantCameraCaptureActivity.kt:35`
- **Verification:** Tap Instant Camera widget on Android desktop; snap photo; verify moment is logged and saved in 1.2 seconds.

---

### IMP-445: App Philosophy Settings Offline Sovereignty Manifesto Interactive Expanders
- **Category:** Brand / Philosophy
- **Current behaviour:** In `lib/dialogs/settings/app_philosophy_settings_page.dart`, the manifesto is displayed as long dense paragraphs.
- **Proposed improvement:** Format the manifesto into elegant collapsible cards: `[Sovereignty: Your Data Never Leaves Your Device]`, `[Horology: Master Time, Don't Be Mastered]`, `[Mindfulness: Digital Tools Should Calm, Not Agitate]`.
- **User benefit:** Inspiring, scannable reading experience celebrating digital sovereignty and mindfulness.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/app_philosophy_settings_page.dart:65`
- **Verification:** Open App Philosophy in settings; explore clean interactive manifesto pillars.

---

### IMP-446: Sobriety Widget Minimal Dial Mode for Discrete Home Screen
- **Category:** Android System Integration / Privacy
- **Current behaviour:** `MinimalSobrietyWidgetProvider.kt:25-60` shows the word "Sober" on the widget, which users may not want visible to coworkers looking at their phone screen.
- **Proposed improvement:** Add an optional `Discrete Mode` for the widget: displays an elegant minimalist circle with day count number only (`42`) and no words.
- **User benefit:** Completely private personal accountability on the home screen that looks like a standard clock or fitness widget to strangers.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MinimalSobrietyWidgetProvider.kt:40`
- **Verification:** Toggle Discrete Mode in Sobriety settings; verify Android home screen widget displays clean number without text labels.

---

### IMP-447: Integrations Settings Calendar ICS Sync Direct Export
- **Category:** Integration / Export
- **Current behaviour:** In `lib/dialogs/settings/integrations_settings_page.dart:40-70`, calendar sync is experimental.
- **Proposed improvement:** Provide a reliable `Export as .ics Calendar File` action that packages all completed Two-Way sessions into a standard iCalendar file compatible with Google Calendar, Apple Calendar, and Outlook.
- **User benefit:** Effortless visual reconciliation of life ledger hours inside standard calendar applications.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/utils/calendar_sync_service.dart:75`
- **Verification:** Tap Export Calendar in Integrations; import generated `.ics` file into Google Calendar; confirm sessions appear as neat calendar blocks.

---

### IMP-448: Update Center Automatic Download on Wi-Fi Only Toggle
- **Category:** Settings / Network Optimization
- **Current behaviour:** In `lib/dialogs/settings/update_center_page.dart`, auto-downloading updates can consume mobile cellular data.
- **Proposed improvement:** Add an explicit setting: `Download Updates on Wi-Fi Only` (default true) checking `ConnectivityManager.isActiveNetworkMetered`.
- **User benefit:** Protects user mobile data plan limits while keeping app security updates current.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/utils/update_service.dart:120`
- **Verification:** Enable Wi-Fi Only; disconnect Wi-Fi; verify update download waits safely for Wi-Fi reconnection.

---

### IMP-449: Settings Dashboard Direct Section Search Shortcut (Press `/`)
- **Category:** Power Users / Keyboard
- **Current behaviour:** In `lib/dialogs/settings_dialog.dart`, opening search requires tapping the magnifying glass.
- **Proposed improvement:** Support standard `/` hardware keyboard shortcut to focus search input instantly on tablets and foldables.
- **User benefit:** Desktop-grade keyboard efficiency for power users with physical keyboards.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings_dialog.dart:140`
- **Verification:** Connect Bluetooth keyboard; press `/` in settings; verify search input activates immediately.

---

### IMP-450: Zero-Knowledge Vault Password Strength Visual Meter
- **Category:** Security / UX
- **Current behaviour:** In `lib/dialogs/vault_password_dialog.dart:60-90`, entering a password shows a standard text field without indicating password entropy.
- **Proposed improvement:** Add an Apple-style 4-segment security meter: Weak (Red), Fair (Orange), Strong (Emerald), Sovereign (Purple) checking length and character diversity.
- **User benefit:** Encourages strong master passphrases protecting sensitive sovereign life ledgers.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/vault_password_dialog.dart:75`
- **Verification:** Type password in Vault dialog; watch security meter dynamically progress from Red -> Orange -> Green.

---

### IMP-451: Quick Note Tile Service Custom Category Pre-Assignment
- **Category:** Android System Integration / Convenience
- **Current behaviour:** Notes captured via the Quick Settings tile default to no category.
- **Proposed improvement:** Add a setting in Quick Note preferences allowing users to set a default category (e.g. `Inbox`, `Ideas`, `Deep Work`) for tile-captured notes.
- **User benefit:** Rapid capture with automatic inbox sorting.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/QuickNoteTileService.kt:45`
- **Verification:** Configure default tile category to 'Ideas'; tap Quick Settings tile; save note; verify note logs under 'Ideas'.

---

### IMP-452: Life Audit Widget Home Screen Daily Hexagon Mini-Card
- **Category:** Android System Integration / Visual Polish
- **Current behaviour:** In `LifeAuditWidgetProvider.kt:30-65`, the widget displays a list of dimension scores.
- **Proposed improvement:** Render a miniature 6-axis polygon radar graphic directly inside the Android home screen RemoteViews widget.
- **User benefit:** Unique, visually striking life balance glanceability right on the Android home launcher.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/LifeAuditWidgetProvider.kt:50`
- **Verification:** Place Life Audit widget on desktop; observe sharp vector-style polygon showing life balance.

---

### IMP-453: Display Settings Screen Edge Curved Corner Radius Offset
- **Category:** Visual Polish / Hardware
- **Current behaviour:** On Android devices with extreme display corner roundings (e.g. Pixel 8, Galaxy S24 Ultra), edge-docked toolbar elements can touch the curved screen edge.
- **Proposed improvement:** Query `WindowInsets.getRoundedCorner()` and dynamically add safe padding on curved screen corners.
- **User benefit:** Pixel-perfect visual safety margin matching individual phone hardware curvatures.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/main.dart:145`
- **Verification:** Test on device with curved display corners; verify floating buttons maintain 16dp clearance from screen curve.

---

### IMP-454: Diagnostics Settings Storage Breakdown Interactive Pie Chart
- **Category:** Storage Management / Polish
- **Current behaviour:** In `DiagnosticsSettingsPage:140`, storage is shown as text numbers (e.g. `Images: 42MB, Audio: 18MB, DB: 4MB`).
- **Proposed improvement:** Render a compact horizontal segmented bar chart visualizing relative storage distribution between Photos, Voice, Database, and Cache.
- **User benefit:** Instantly understand what asset types are consuming local device disk space.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:150`
- **Verification:** View Diagnostics settings; inspect colorful storage breakdown bar chart.

---

### IMP-455: App Permissions Settings Usage Stats Permission Deep-Link
- **Category:** Android System Integration / UX
- **Current behaviour:** In `AppPermissionsSettingsPage:75`, enabling Usage Stats opens general settings, requiring users to manually search for "Usage Access".
- **Proposed improvement:** Launch direct `Settings.ACTION_USAGE_ACCESS_SETTINGS` intent focusing straight on NoteKar in the system list.
- **User benefit:** Eliminates 4 taps through Android system menus to enable Digital Wellbeing tracking.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/settings/app_permissions_settings_page.dart:78`
- **Verification:** Tap 'Grant Usage Access'; verify Android opens directly to NoteKar usage permission toggle.

---

### IMP-456: Floating Timer Service Notification Mute During App Foregrounding
- **Category:** Reliability / Cleanliness
- **Current behaviour:** In `FloatingTimerService.kt:70-76`, the foreground service notification continues displaying in the shade even while the user is actively inside NoteKar.
- **Proposed improvement:** When `FloatingTimerService.setAppInForeground(true)`, lower notification priority to minimum silent channel; restore when app enters background.
- **User benefit:** Clean notification shade with zero redundant status alerts when already viewing the app.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:72`
- **Verification:** Open NoteKar; pull shade; verify floating timer notification is silent and collapsed.

---

### IMP-457: Modes & Categories Settings Category Merge Tool
- **Category:** Data Organization / UX
- **Current behaviour:** If a user created both "Deep Work" and "Focus", there is no way to combine them without manually editing dozens of moments.
- **Proposed improvement:** Add a "Merge Categories" action: `"Merge [Category A] into [Category B] (Reassigns all moments)"`.
- **User benefit:** Painless consolidation of historical category tags as personal workflows evolve.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/modes_categories_settings_page.dart:240`
- **Verification:** Merge 'Writing' into 'Deep Focus'; verify all 15 past writing moments now display 'Deep Focus'.

---

### IMP-458: Capture Settings Voice Recording Automatic Noise Suppression Toggle
- **Category:** Audio / Quality
- **Current behaviour:** Voice recordings use default microphone input without configuring audio processing flags.
- **Proposed improvement:** Configure `MediaRecorder.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION)` with active noise suppression and acoustic echo cancellation.
- **User benefit:** Crystal-clear vocal recordings that filter out street traffic, fan hum, and background room reverb.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:190`
- **Verification:** Record voice memo in noisy coffee shop; verify speech is crisp while background cafe clatter is suppressed.

---

### IMP-459: Activity Tags Settings Bulk Tag Renaming Propagation
- **Category:** Data Integrity / Power Users
- **Current behaviour:** Renaming a tag in settings only renames future autocomplete options; past notes remain tagged with the old string.
- **Proposed improvement:** Offer a checkbox: `"Update in all 42 past moments"` that executes a background batch update across Isar moments.
- **User benefit:** Effortless tag taxonomy refactoring with guaranteed backward consistency.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/activity_tags_settings_page.dart:140`
- **Verification:** Rename `#study` to `#learning`; check 'Update past moments'; confirm all past moments reflect `#learning`.

---

### IMP-460: Zero-Knowledge Vault Password Recovery Hint Field
- **Category:** Security / UX
- **Current behaviour:** In `VaultEncryptionService`, if a user forgets their master vault password, encrypted backups are mathematically unrecoverable.
- **Proposed improvement:** Allow users to store an unencrypted `password_hint` metadata field inside the `.notekar-vault` file header.
- **User benefit:** Invaluable memory aid that helps users remember their sovereign passphrase years down the road.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/vault_encryption_service.dart:88`
- **Verification:** Export vault with hint "Mother's maiden street"; inspect file; confirm hint displays safely during import without revealing password.

---

### IMP-461: Display Settings System Font Size Scaling Lock
- **Category:** Accessibility / Personalization
- **Current behaviour:** In `lib/main.dart:394-398`, `textScaler` clamps between 0.85 and 2.0. Users who prefer fixed typography layout cannot lock text scale independently of Android OS accessibility settings.
- **Proposed improvement:** Add an option: `Ignore System Font Scaling` that locks NoteKar text scaling strictly to 1.0x.
- **User benefit:** Complete visual layout stability for users whose elderly relatives use extreme 2.5x system text on shared family tablets.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/display_settings_page.dart:170`
- **Verification:** Enable Ignore System Scale; change Android OS text size to Maximum; verify NoteKar layout remains perfectly proportioned.

---

### IMP-462: Quick Note Activity Multi-Line Dynamic Auto-Expanding Textfield
- **Category:** Android System Integration / UX
- **Current behaviour:** In `QuickNoteActivity.kt:95-110`, the input field height is fixed, requiring vertical scrolling after 4 lines of text.
- **Proposed improvement:** Allow text input to dynamically grow from 2 lines up to 8 lines before enabling scroll.
- **User benefit:** Comfortable, spacious drafting experience for quick multi-paragraph thoughts.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/QuickNoteActivity.kt:100`
- **Verification:** Type 6 lines in Quick Note dialog; watch text container smoothly expand to accommodate text comfortably.

---

### IMP-463: Diagnostics Settings Export Full System Telemetry Report
- **Category:** Support / Debuggability
- **Current behaviour:** Diagnostics page has a "Copy Diagnostics" button that copies brief system specs.
- **Proposed improvement:** Generate a comprehensive markdown system report: OS Version, API Level, ABI Architecture, Display DPI, Storage Space, Isar Version, Workmanager Health, and Active Audio Drivers.
- **User benefit:** Comprehensive technical diagnostics that expedite open-source bug resolution.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:95`
- **Verification:** Tap 'Copy Full Telemetry'; paste into notepad; confirm complete hardware and runtime environment profile.

---

### IMP-464: Data Backup Settings Automatic Nightly Cloud Sync Documentation Guide
- **Category:** Education / Sovereignty
- **Current behaviour:** Many users ask how to backup NoteKar to Google Drive, Nextcloud, or Synology without compromising offline sovereignty.
- **Proposed improvement:** Add a dedicated guide: `"How to Set Up Sovereign Automated Sync using Syncthing, Nextcloud, or FolderSync"`.
- **User benefit:** Empowers users to achieve zero-knowledge encrypted multi-device sync without proprietary third-party servers.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/data_backup_settings_page.dart:110`
- **Verification:** Open Data Backup; tap 'Sovereign Cloud Sync Guide'; read step-by-step instructions for Syncthing and Nextcloud.

---

### IMP-465: Floating Timer Service Double-Tap to End Session Shortcut
- **Category:** Android System Integration / Shortcuts
- **Current behaviour:** In `FloatingTimerService.kt:75`, ending a session requires expanding the card, selecting action, and tapping Out.
- **Proposed improvement:** Add a double-tap gesture on the floating circle bubble that ends the session with a haptic confirmation tick.
- **User benefit:** End focus sessions in 0.2 seconds from any screen on your Android phone.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:80`
- **Verification:** Double-tap floating bubble; observe session ends cleanly with confirmation toast and bubble docks safely.

---

### IMP-466: App Philosophy Settings Offline-First Manifest Cryptographic Signature
- **Category:** Brand / Authenticity
- **Current behaviour:** The manifesto is signed with text author names.
- **Proposed improvement:** Include the developer team's public PGP key fingerprint and GitHub release signing key hash in the About page.
- **User benefit:** Undeniable cryptographic provenance verifying that binary updates originate from trusted sovereign stewards.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/dialogs/settings/app_philosophy_settings_page.dart:95`
- **Verification:** Inspect About footer; verify verified PGP signature fingerprint displayed for binary verification.

---

### IMP-467: Personal Profile Settings Sovereign Export Card Avatar Badge Customization
- **Category:** Personalization / Sharing
- **Current behaviour:** In `lib/dialogs/shareable_profile_card_sheet.dart:50`, user cards display default avatar badges.
- **Proposed improvement:** Allow users to choose their avatar badge glyph: (e.g. `👑 Sovereign`, `⚡ Focus Monk`, `🛡️ Guardian`, `🧘 Zen Master`).
- **User benefit:** Express personal mastery identity on exported profile and milestone summary cards.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/shareable_profile_card_sheet.dart:65`
- **Verification:** Select 'Focus Monk' badge; view exported profile card; confirm title and glyph reflect chosen identity.

---

### IMP-468: Update Center Page Automatic Update Check Frequency Setting
- **Category:** Settings / Network
- **Current behaviour:** Update checking checks on launch or manual button press.
- **Proposed improvement:** Add a setting: `Check for Updates: On App Launch | Weekly | Manual Only`.
- **User benefit:** Total control for users who prefer strict air-gapped zero-network operation.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/update_center_page.dart:110`
- **Verification:** Set to 'Manual Only'; verify zero background network requests are ever dispatched during launch.

---

### IMP-469: Advanced Settings Low-Memory Trim Mode for Budget 2GB/3GB Devices
- **Category:** Performance / Device Compatibility
- **Current behaviour:** Timeline caches 100 moments in memory. On budget Android Go or 2GB RAM phones, this can cause OS memory pressure.
- **Proposed improvement:** Add an explicit `Ultra-Low Memory Mode` setting that caps memory pagination to 25 items and reduces image cache size from 100MB to 20MB.
- **User benefit:** Flawless stability with zero out-of-memory crashes on sub-$100 entry-level Android devices.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/adaptive_engine.dart:120`
- **Verification:** Enable Ultra-Low Memory Mode; monitor memory profile via ADB; verify RSS memory usage remains under 65MB.

---

### IMP-470: Quick Settings Tile Quick Note Audio Memo Direct Shutter
- **Category:** Android System Integration / Convenience
- **Current behaviour:** The Quick Note tile opens a text dialog. Users wanting to record an immediate voice thought must open the dialog, then tap record.
- **Proposed improvement:** Add an optional secondary Quick Settings tile: `"NoteKar Voice Memo"` that begins recording immediately upon tile tap.
- **User benefit:** 1-tap immediate dictation of fleeting ideas while driving or walking.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/AndroidManifest.xml:390`
- **Verification:** Add Voice Memo tile to Quick Settings; tap tile; verify recording starts instantly with audio indicator in notification shade.

---

### IMP-471: App Permissions Settings Microphone Privacy Indicator Assurance
- **Category:** Privacy / Transparency
- **Current behaviour:** When granting microphone permission, users worry whether NoteKar listens in the background.
- **Proposed improvement:** Display an explicit privacy architecture card: `"NoteKar only accesses the microphone when you deliberately tap Record. Audio is never streamed or uploaded."`.
- **User benefit:** Absolute clarity and reassurance regarding hardware microphone usage.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/app_permissions_settings_page.dart:115`
- **Verification:** Inspect Microphone section in Permissions settings; read clear offline privacy architecture statement.

---

### IMP-472: Display Settings E-Ink Refresh Mode Full Screen Flush Animation
- **Category:** E-Ink Compatibility / Hardware
- **Current behaviour:** On Onyx Boox, Kindle, and Hisense E-Ink devices, rapid scrolling leaves ghosting artifacts on the electronic ink display.
- **Proposed improvement:** Add an `E-Ink Full Screen Refresh on Scroll Stop` setting that briefly flashes the display to flush electronic ink ghosting.
- **User benefit:** Crystal-clear, ghost-free reading on dedicated electronic paper displays.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/display_settings_page.dart:180`
- **Verification:** Enable E-Ink mode; scroll timeline; observe subtle clean display flush when scrolling stops.

---

### IMP-473: Data Backup Settings Export Encrypted Archive Password Confirmation Double-Check
- **Category:** Security / Reliability
- **Current behaviour:** When exporting a `.notekar-vault` backup, entering a password has a single field. A typo during backup creation could render the backup unopenable.
- **Proposed improvement:** Require password confirmation (`Confirm Password` field) before initiating AES-256-GCM encryption.
- **User benefit:** Protects users from creating unrecoverable encrypted archives due to keyboard typing slips.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/vault_password_dialog.dart:85`
- **Verification:** Try to export vault with mismatched passwords; confirm validation error prevents file creation.

---

### IMP-474: Floating Timer Service Landscape Orientation Positioning Memory
- **Category:** Android System Integration / Ergonomics
- **Current behaviour:** When rotating the device to landscape (e.g. playing a game or watching a tutorial), the floating bubble can jump to the bottom edge.
- **Proposed improvement:** Track separate landscape and portrait coordinates in `SharedPreferences`, restoring the appropriate coordinates on configuration changes.
- **User benefit:** Bubble stays in your preferred corner whether holding phone vertically or horizontally.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:95`
- **Verification:** Rotate phone to landscape, move bubble to top-right corner; rotate to portrait, then back; confirm landscape position is remembered.

---

### IMP-475: Diagnostics Settings Clear Network Cache One-Tap Action
- **Category:** Performance / Storage
- **Current behaviour:** Cached APK files and changelog caches can accumulate in temp directories.
- **Proposed improvement:** Add a "Purge Download & Network Cache" action with instant toast confirming MB freed.
- **User benefit:** Clean local storage without wiping database moments or personal settings.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:160`
- **Verification:** Tap 'Purge Download Cache'; observe toast confirming freed space and verify temp directory is wiped.

---

### IMP-476: Personal Profile Settings Milestone Badge Share Sheet Custom Branding Toggle
- **Category:** Personalization / Privacy
- **Current behaviour:** Exported share cards always include the NoteKar footer branding.
- **Proposed improvement:** Add a toggle `Show NoteKar Watermark on Exported Cards` (default on, can be toggled off for clean personal journaling).
- **User benefit:** Respects user creative autonomy for cards shared on personal blogs or portfolios.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/personal_profile_settings_page.dart:160`
- **Verification:** Disable watermark toggle; export profile card; verify clean footer without app branding.

---

### IMP-477: Logging Settings Circular Buffer Log Rotation Memory Guard
- **Category:** Performance / Architecture
- **Current behaviour:** In `AppLogger:20`, logs accumulate in memory up to 500 entries before trimming.
- **Proposed improvement:** Use a true circular ring buffer (`CircularBuffer<LogEntry>(300)`) preventing micro-reallocations during heavy log sessions.
- **User benefit:** Zero memory fragmentation and constant-time `O(1)` log additions.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/utils/app_logger.dart:25`
- **Verification:** Run 1,000 log events; verify memory footprint remains completely flat.

---

### IMP-478: Quick Note Activity Swipe Down on Handle to Dismiss
- **Category:** Android System Integration / Gestures
- **Current behaviour:** In `QuickNoteActivity.kt:85`, dismissing requires tapping outside the dialog or pressing back.
- **Proposed improvement:** Add an Apple HIG top grabber bar to the dialog: dragging down on the bar dismisses the activity with a smooth slide-down animation.
- **User benefit:** Natural, fluid mobile gesture ergonomics matching modern Android sheets.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/QuickNoteActivity.kt:90`
- **Verification:** Swipe down on top grabber bar in Quick Note; observe activity dismiss smoothly.

---

### IMP-479: Display Settings Dynamic Color (Material You) Theme Integration
- **Category:** Android System Integration / Visual Polish
- **Current behaviour:** Accent colors in `Palette` are selected from 12 predefined presets.
- **Proposed improvement:** Add a `Dynamic Wallpaper Accent (Material You)` option that extracts the primary seed color from Android system wallpaper via `dynamic_color`.
- **User benefit:** Complete native visual harmony with the user's Android 13/14/15 system wallpaper palette.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/models/palette.dart:180`
- **Verification:** Enable Dynamic Wallpaper Accent; change phone wallpaper; confirm NoteKar buttons and clock dials adopt wallpaper palette.

---

### IMP-480: Zero-Knowledge Vault Import Version Incompatibility Clear Warning
- **Category:** Reliability / Architecture
- **Current behaviour:** In `VaultEncryptionService`, attempting to import a corrupted or newer-schema vault file can throw a generic parsing exception.
- **Proposed improvement:** Validate vault schema version header: if file version > app version, display a clear advisory: `"This vault was created with a newer version of NoteKar (v2.4). Please update NoteKar to restore."`.
- **User benefit:** Unambiguous guidance preventing user confusion when restoring backups across devices.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/services/vault_encryption_service.dart:140`
- **Verification:** Attempt to import mock vault with schema v99; observe clear update requirement dialog.

---

### IMP-481: Floating Timer Service Ambient Sleep Mode Detection
- **Category:** Android System Integration / Battery
- **Current behaviour:** In `FloatingTimerService.kt:85`, if the user puts the phone down and the screen goes dark, the chronometer textview continues updating every second in the background.
- **Proposed improvement:** Register a `BroadcastReceiver` for `ACTION_SCREEN_OFF` / `ACTION_SCREEN_ON` in the service; halt View redraws while display is off.
- **User benefit:** Drastically extends battery life during 8-hour continuous study or workday tracking.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:90`
- **Verification:** Check battery consumption via ADB during 4-hour session with screen off; confirm zero View draw wakeups.

---

### IMP-482: Modes & Categories Settings Category Icon Glyph Picker
- **Category:** Personalization / Visual Polish
- **Current behaviour:** Categories in `ModesCategoriesSettingsPage` have color tags but no custom iconography.
- **Proposed improvement:** Allow assigning an icon glyph to each category (e.g. 💼 Work, 🔬 Research, 🏃 Athletics, 🎨 Creative).
- **User benefit:** Instant visual identification of categories on pills, cards, and charts.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/modes_categories_settings_page.dart:210`
- **Verification:** Assign 💼 icon to Work; view home screen; verify briefcase glyph renders in category pill.

---

### IMP-483: Diagnostics Settings Database SQLite/Isar File Size Live Meter
- **Category:** Storage Management
- **Current behaviour:** Database size is shown as part of general app storage.
- **Proposed improvement:** Display the exact file weight of `notekar_entries_v1.isar` and `notekar_trash_v1.isar` separately: `"Active Database: 3.2 MB • Trash: 1.1 MB"`.
- **User benefit:** Transparent technical insight into raw database file growth over years of logs.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:145`
- **Verification:** View Diagnostics; observe precise MB weights for primary database vs trash database.

---

### IMP-484: Quick Note Activity Keyboard Done Action Behavior
- **Category:** Android System Integration / UX
- **Current behaviour:** In `QuickNoteActivity.kt:105`, pressing the virtual keyboard action key inserts a newline.
- **Proposed improvement:** Add a toggle in capture settings: `Keyboard Action: Newline | Save Note Immediately`.
- **User benefit:** 1-tap save from keyboard action key for ultra-fast single-sentence captures.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/QuickNoteActivity.kt:108`
- **Verification:** Set keyboard action to Save; type thought in Quick Note; tap checkmark on virtual keyboard; verify note saves and closes.

---

### IMP-485: Display Settings High Contrast Accent Luminescence Override
- **Category:** Accessibility / Visual Polish
- **Current behaviour:** When High Contrast mode is enabled in `lib/models/palette.dart:98`, backgrounds deepen, but some pastel accent colors retain low text contrast.
- **Proposed improvement:** Force accent colors to their highest-contrast saturated tier (e.g. Electric Cyan, Pure Amber, Vivid Emerald) when High Contrast mode is active.
- **User benefit:** Exceeds WCAG AAA 7:1 maximum contrast ratios for severely visually impaired users.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/models/palette.dart:105`
- **Verification:** Enable High Contrast mode; inspect button and tag contrast; confirm AAA rating across all elements.

---

### IMP-486: Life Audit Page Dimension History Trend Sparklines
- **Category:** Analytics / Depth
- **Current behaviour:** `LifeAuditPage` shows current scores (e.g. Health: 75%). It cannot show whether health was higher or lower last month.
- **Proposed improvement:** Add a miniature 6-month historical sparkline next to each life dimension score.
- **User benefit:** Long-term holistic perspective on which areas of life are flourishing and which require nurturing.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/life_audit_page.dart:180`
- **Verification:** Complete life audits across multiple months; observe historical trend sparklines beside each dimension.

---

### IMP-487: Floating Timer Service Transparent Mode During Video Playback
- **Category:** Android System Integration / UX
- **Current behaviour:** When watching YouTube or Netflix with the floating bubble active, the opaque bubble blocks subtitles or video corners.
- **Proposed improvement:** Add an option: `Dim Bubble to 25% Opacity When Inactive` that makes the floating timer whisper-thin and translucent when not being touched.
- **User benefit:** Zero obstruction when watching lectures or media while timing work in background.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:110`
- **Verification:** Let floating bubble sit untouched for 5 seconds; observe opacity fade gently to 25% translucency.

---

### IMP-488: Data Backup Settings Automatic CSV Export Schedule
- **Category:** Data Sovereignty / Automation
- **Current behaviour:** CSV exports must be performed manually.
- **Proposed improvement:** Add an option `Automated Weekly CSV Export to Documents` that automatically writes an unencrypted `notekar_weekly.csv` file into the user's public Documents directory every Sunday night.
- **User benefit:** Guaranteed perpetual human-readable plaintext ledger backup accessible with any spreadsheet software on Earth.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/data_backup_settings_page.dart:130`
- **Verification:** Enable weekly CSV export; run midnight maintenance; verify `notekar_weekly.csv` updates cleanly in Documents folder.

---

### IMP-489: App Lock Failed Attempts Delay Throttle (Brute Force Guard)
- **Category:** Security / Reliability
- **Current behaviour:** In `lib/dialogs/privacy_overlay.dart:130`, a user or attacker can enter PIN codes rapidly without exponential back-off delays.
- **Proposed improvement:** Implement exponential back-off security throttling: after 3 failed attempts, require a 30-second wait; after 5 attempts, require a 5-minute cooldown.
- **User benefit:** Mathematically renders 4-digit and 6-digit PIN brute forcing impossible even if physical device is stolen.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/privacy_overlay.dart:135`
- **Verification:** Enter wrong PIN 3 times; verify 30-second countdown cooldown timer disables keypad entry.

---

### IMP-490: Update Center Page Automatic Update Integrity Pre-Flight Check
- **Category:** Reliability / Security
- **Current behaviour:** In `UpdateService.dart`, downloading an APK directly installs if checksum matches.
- **Proposed improvement:** Verify Android package signature (`PackageInfo.signatures`) before launching package installer intent, ensuring the update was signed with the identical release certificate.
- **User benefit:** 100% defense against malicious APK tampering or hijacked mirrors.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/update_service.dart:160`
- **Verification:** Attempt update with test-signed APK; verify integrity pre-flight blocks installation with certificate mismatch alert.

---

### IMP-491: Activity Tags Settings Merge Duplicate Tags Tool
- **Category:** Organization / Power Users
- **Current behaviour:** Users who typed both `#deep-work` and `#deepwork` have two fragmented tag categories.
- **Proposed improvement:** Add a "Merge Tags" tool in Activity Tags settings: select `#deep-work` and reassign all historical moments to `#deepwork` in 1 tap.
- **User benefit:** Clean, unified tag taxonomy without fragmented analytics.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/activity_tags_settings_page.dart:150`
- **Verification:** Merge `#deep-work` into `#deepwork`; confirm search for `#deepwork` now returns both sets of moments.

---

### IMP-492: Diagnostics Settings Isar Database Compaction & Defrag Tool
- **Category:** Performance / Database
- **Current behaviour:** In `lib/utils/moment_repository.dart`, deleting moments leaves empty pages in the Isar database file.
- **Proposed improvement:** Add a "Compact & Defragment Database" button in Diagnostics that runs Isar compaction, shrinking database file size and optimizing B-tree index layouts.
- **User benefit:** Reclaims disk space and accelerates query lookup speeds after large batch deletions.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/utils/moment_repository.dart:210`
- **Verification:** Delete 500 moments; tap 'Compact Database'; verify database file size decreases on disk.

---

### IMP-493: Personal Profile Settings Sovereign Export Card Anonymous Mode
- **Category:** Privacy / Social
- **Current behaviour:** `ShareableProfileCardSheet` always displays the user's name or username.
- **Proposed improvement:** Add an "Incognito / Anonymous" toggle on the card export sheet that replaces personal name with `"Sovereign NoteKar User"`.
- **User benefit:** Safe, anonymous sharing of productivity and milestone achievements on public social forums (Reddit, X) without doxxing real identity.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/shareable_profile_card_sheet.dart:80`
- **Verification:** Toggle Anonymous Mode on profile card export; verify name renders as 'Sovereign Practitioner' with personal initials removed.

---

### IMP-494: Floating Timer Service Audio Click on Pause/Resume from Overlay
- **Category:** Tactile Feedback / Audio
- **Current behaviour:** In `FloatingTimerService.kt:75`, tapping Pause or Resume on the floating overlay card operates silently.
- **Proposed improvement:** Play the authentic mechanical shutter click (`SoundPool`) synchronized with a light tactile click.
- **User benefit:** Satisfying physical confirmation that the floating timer state changed while using other apps.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:76`
- **Verification:** Tap Pause on floating bubble; hear crisp acoustic tick and feel tactile notch.

---

### IMP-495: Display Settings AMOLED Pure Black Card Insets
- **Category:** Visual Polish
- **Current behaviour:** In AMOLED theme, `NkCard` uses `p.surface2` (`#0D0D0E`), which has a slight dark grey tint.
- **Proposed improvement:** Add an option: `AMOLED True Black Surface Cards` that renders card containers as pure `#000000` with ultra-fine `#333333` hairline borders.
- **User benefit:** True zero-pixel OLED power savings and stunning seamless black aesthetic.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/models/palette.dart:125`
- **Verification:** Enable True Black Cards; inspect cards on OLED phone in dark room; verify zero pixel glow.

---

### IMP-496: Quick Note Activity Keyboard Spellcheck & Autocorrect Enabler
- **Category:** Android System Integration / Productivity
- **Current behaviour:** In `QuickNoteActivity.kt:17`, the `EditText` input type is `TYPE_CLASS_TEXT | TYPE_TEXT_FLAG_MULTI_LINE`. On some OEM keyboards, autocorrect and predictive words are suppressed.
- **Proposed improvement:** Explicitly add `InputType.TYPE_TEXT_FLAG_AUTO_CORRECT | InputType.TYPE_TEXT_FLAG_CAP_SENTENCES`.
- **User benefit:** Full predictive typing speed and grammar corrections inside quick note captures.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/QuickNoteActivity.kt:18`
- **Verification:** Type "teh" in Quick Note dialog; confirm Gboard autocorrects cleanly to "the".

---

### IMP-497: Advanced Settings Factory Reset Multi-Step Confirmation Shield
- **Category:** Reliability / Catastrophic Safety
- **Current behaviour:** In `lib/dialogs/reset_sheets.dart:60-90`, factory reset requires confirmation, but could be tapped quickly in two taps.
- **Proposed improvement:** Require the user to type the word `"RESET"` or enter their biometric authentication before factory reset can execute.
- **User benefit:** 100% foolproof protection against catastrophic accidental wipe of lifetime ledgers.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/reset_sheets.dart:75`
- **Verification:** Initiate Factory Reset; confirm button remains disabled until user explicitly types 'RESET' into verification box.

---

### IMP-498: Diagnostics Settings Memory Leak Heap Monitor
- **Category:** Performance / Diagnostics
- **Current behaviour:** In `DiagnosticsSettingsPage`, memory usage shows current RSS memory.
- **Proposed improvement:** Add a "Check for Memory Leaks" diagnostic test that verifies whether closed sheets and image controllers have been properly garbage-collected.
- **User benefit:** Immediate developer and power-user assurance of zero memory leaks during marathon usage.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:170`
- **Verification:** Open and close 10 sheets; run leak check in Diagnostics; verify 0 lingering controllers detected.

---

### IMP-499: Reminders Settings Smart Shift-Worker Rhythm Scheduler
- **Category:** Accessibility / Routine
- **Current behaviour:** Daily reminders assume a standard 9-to-5 day. Shift workers working night shifts receive alerts while sleeping.
- **Proposed improvement:** Add a "Shift Worker Schedule" mode that lets users flip day/night reminder orientations.
- **User benefit:** Inclusive support for nurses, doctors, emergency responders, and night-shift workers.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/reminders_settings_page.dart:95`
- **Verification:** Toggle Shift Worker mode; set sleep schedule 08:00 to 16:00; confirm reminders adjust away from sleeping window.

---

### IMP-500: Zero-Knowledge Vault Export Checksum File (.sha256) Generation
- **Category:** Security / Data Sovereignty
- **Current behaviour:** Exporting `.notekar-vault` saves the vault file alone.
- **Proposed improvement:** Simultaneously export a companion `.notekar-vault.sha256` text file containing the cryptographic hash.
- **User benefit:** Standardized verification format allowing users to verify archive integrity via terminal (`sha256sum -c backup.notekar-vault.sha256`).
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/vault_encryption_service.dart:120`
- **Verification:** Export vault backup; inspect exported files; verify companion `.sha256` text file is created alongside.

---

### IMP-501: Floating Timer Service Screen Recording Watermark Guard
- **Category:** Privacy / Android System Integration
- **Current behaviour:** When screen recording a tutorial or video call, the floating chronometer overlay appears in the recording.
- **Proposed improvement:** Add an option: `Hide Floating Overlay in Screen Captures` applying `LayoutParams.FLAG_SECURE` to the floating window.
- **User benefit:** Keep floating timer visible on your physical screen without recording it into screen capture videos.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/FloatingTimerService.kt:65`
- **Verification:** Start screen recording with flag active; verify recorded video does not capture the floating bubble overlay.

---

### IMP-502: Display Settings Refresh Rate Lock (60Hz / 90Hz / 120Hz)
- **Category:** Performance / Battery Optimization
- **Current behaviour:** Display refresh rate uses default Android OS display policy, which can switch between 60Hz and 120Hz dynamically.
- **Proposed improvement:** Allow users to force 60Hz lock in Display settings: `Force 60Hz Low-Power Frame Rate`.
- **User benefit:** Extends screen battery life by up to 25% for users reading or timing static desk sessions.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:290`
- **Verification:** Enable 60Hz lock; inspect Android developer refresh rate counter; verify display stays pinned at 60Hz.

---

### IMP-503: Quick Note Tile Service Instant Voice Note Quick Tile
- **Category:** Android System Integration / Convenience
- **Current behaviour:** Quick Settings only has a text note tile.
- **Proposed improvement:** Add `QuickVoiceTileService` allowing users to tap a tile in Quick Settings and begin recording immediately.
- **User benefit:** Hands-free capture when walking, driving, or holding groceries.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/AndroidManifest.xml:405`
- **Verification:** Add Quick Voice tile; tap tile; verify recording starts with a gentle haptic confirmation.

---

### IMP-504: Diagnostics Settings Single-Tap Database Snapshot Backup
- **Category:** Reliability / Power Users
- **Current behaviour:** Manual backup requires navigating to Data & Backup -> Export Backup.
- **Proposed improvement:** Add an instant "Quick Snapshot Now" button in Diagnostics that creates a verified timestamped snapshot in 1 tap with haptic confirmation.
- **User benefit:** Instant zero-friction safety snapshot before testing experimental features or bulk edits.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart:180`
- **Verification:** Tap 'Quick Snapshot Now'; feel instant tactile click and see confirmation toast: `"Snapshot saved safely"`.

---

### IMP-505: Settings Master Search Deep Linking into Specific Form Inputs
- **Category:** Search Intelligence / UX
- **Current behaviour:** Tapping a search result in `SettingsDialogSearch` navigates to the subpage, but doesn't scroll to or highlight the specific toggle.
- **Proposed improvement:** Pass a target key to the subpage: auto-scroll to the target switch tile and flash it with a gentle 300ms accent highlight glow.
- **User benefit:** Zero hunting: immediately locate the exact setting you searched for.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings_dialog.dart:170`
- **Verification:** Search for "Highlight Seconds"; tap result; observe Display settings open and smoothly scroll to highlight the exact switch row.
