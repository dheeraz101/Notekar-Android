# NOTEKAR — Protected Features & Architecture Policy

> **Directive**: Strict Code Preservation Over Code Generation.  
> Existing working features, tests, and models are **permanently protected**.  
> No existing functionality may be removed, stubbed out, or altered without explicit user approval.

---

## 1. Prime Invariant: The Non-Negotiable Principle

Any modification to NoteKar must adhere to these non-negotiable rules:
1. **Never Remove or Simplify Working Code**: Functioning business logic, services, dialogs, and tests must not be simplified or removed merely because a different implementation looks cleaner.
2. **Surgical, Additive Edits Only**: Any change must be isolated to the exact problem being solved. Unsolicited architectural refactoring or mass cosmetic reformatting of untouched code is strictly prohibited.
3. **Zero Test Regressions**: All 74 existing test suites (559 tests) must pass with 100% success rate after any change. Never comment out, delete, or weaken a failing test.
4. **100% Offline-First & Zero Telemetry**: Never introduce network analytics, tracking SDKs (Google Analytics, Firebase, Mixpanel), or advertising pixels. All data must remain strictly on-device.

---

## 2. Codified Production Domain Invariants

Every engineer and agent must uphold these 11 production invariants codified in `.agents/rules/11-notekar-domain-invariants.md`:

### Invariant 1: Android & Flutter SharedPreferences Type Guardrail
- **Rule**: Flutter stores `List<String>` in Android SharedPreferences as a `Set<String>`.
- **Constraint**: In Kotlin code, always access these using `getStringSet(key, null)` or inspect both JSON string format and `getStringSet` safely with try-catch. Failure to follow this causes fatal `ClassCastException` crashes on native Android startup.
- **Explicit State Push**: For critical native UI components (app widgets, quick actions, notifications), always push synchronized state via `MethodChannel` payloads in addition to writing SharedPreferences.

### Invariant 2: Background Log Session Mode Invariance
- **Rule**: Active category propagation must be immediate and synchronous.
- **Constraint**: When an `in` session entry arrives with a non-null, non-'All' category in `_syncBackgroundLogs()`, `_activeCategory` must be immediately updated to match that category before pushing state back to native Android. Never send a stale `'All'` fallback while an active session is running.
- **Reset Guards**: Preferences such as `m-reset-mode-on-close` must strictly be guarded by `_sessionStart == null`. Never reset the active category if a live session is currently in progress.

### Invariant 3: Timeline Session Lifecycle, Gap Consumption, and Boundary Invariants
- **Contiguous Session Boundaries**: When Session A ends at timestamp $T$ (`out`) and Session B starts at timestamp $T$ (`in`), if an active unclosed session started prior to $T$, the `out` at $T$ closes that preceding session. The `in` at $T$ then opens the subsequent session.
- **Untracked Gap Consumption**: Any manual entry seeded from an untracked gap must strictly produce a completed session (`lockToSession: true` / `_isSession = true`), never an instantaneous single point-in-time log. Claiming rest or logging a manual session immediately claims the interval (`claimedGaps.add('$startMs-$endMs')`), suppressing the gap card optimistically in both Normal and Calendar views.
- **Live Session Termination**: Ending an active live session (`_endLiveSession`) must never abort due to downstream moments. It calculates an authoritative effective timestamp, inserts the terminal `out` moment, and guards against rapid multi-taps with `_isEndingLiveSession`.

### Invariant 4: Multi-Media Attachment Invariance & Lifecycle Guardrails
- **Non-Destructive Staging**: Dialogs (`NoteDialog`, `BigNoteDialog`, `QuickNoteActivity`) must never treat media as single scalar fields that clobber existing assets. Adding an additional photo or voice note appends to the staged list; removing an attachment unlinks only that specific item.
- **Relative Sandbox Paths**: Media paths stored in database entities (`Moment`) or native JSON payloads must strictly use invariant relative paths (`images/img_<timestamp>_<random>.jpg`, `voice/voice_<timestamp>_<random>.m4a`) delimited by pipe `|`. Never persist absolute Android paths (`/data/user/0/...`).
- **Cascade Purge on Permanent Delete**: Moving to trash never deletes files from disk. Permanent purge from trash iterates through and deletes all linked image and voice assets from disk. Maximum cap is enforced (5 photos, 5 voice notes per moment).

### Invariant 5: Notification Action & Quick Action Uniformity
- **Label Brevity**: Notification action titles must never exceed 8 characters (e.g. `📝 Log`, `🏷️ Modes`, `▶ Start`, `⏹ OUT`).
- **Semantic Separation**: `Log` opens fast point-in-time note capture (`EXTRA_LOG_TYPE = "single"`). `Modes` opens category/goal configuration; in Two-Way standby, Modes leads exclusively to starting a session (`▶ Start`).
- **Cap**: Maximum 3 `addAction()` intents per notification builder state to prevent Android OEM layout truncation.

### Invariant 6: RemoteViews Background State Sync
- **Rule**: When home screen widgets trigger background actions while Flutter is suspended or killed, the native receiver must synchronously update both `FlutterSharedPreferences` AND `widgetPrefs`, and invoke `updateAllWidgets(context)` immediately. RemoteViews UI and chronometers must never freeze waiting for the Flutter isolate.

### Invariant 7: Notification Small Icons Invariant
- **Rule**: Status bar and lockscreen notifications must always use flat monochrome vector assets (`R.drawable.ic_stat_notekar`).
- **Constraint**: Never pass `R.mipmap.*` adaptive XML icons to `NotificationCompat.Builder.setSmallIcon()`; this causes fatal crashes or silent notification drops on Samsung, Xiaomi, and Google Pixel devices.

### Invariant 8: CI & Gradle Build Resilience
- **Rule**: Pin `github/codeql-action` to compatible versions (`@v4.39.1`) with `tools: linked`. Pre-provision Gradle wrapper `-bin.zip` in `$HOME/.gradle/wrapper/dists/...` with retry logic. Never inject `allprojects { repositories { ... } }` into `$HOME/.gradle/init.d/` if composite projects exist.

### Invariant 9: Flutter ByteData Buffer Slicing Invariant
- **Rule**: Never call `byteData.buffer.asUint8List()` without arguments.
- **Constraint**: Always pass slice offsets:
  ```dart
  final uint8List = byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
  ```
  Omitting parameters starts from byte 0 of the underlying shared buffer, corrupting images and audio.

### Invariant 10: Database Engine Migration Safety
- **Rule**: Never assume a clean install or empty state. Existing users will have databases on disk from earlier versions.
- **Constraint**: Check legacy database files and secure storage keys before initializing empty stores. Maintain fallback data bridges for seamless migration.

### Invariant 11: Touch Targets & Accessibility
- **Rule**: All interactive controls must strictly meet or exceed **48×48dp** (`NkTouchTarget.minInteractive`).
- **Constraint**: If visual elements are smaller (e.g. 24dp icons), wrap with touch slop padding to ensure accessibility compliance.

---

## 3. Inventory of Protected Core Features

| Feature Subsystem | Key Files | Protected Capabilities |
| :--- | :--- | :--- |
| **Chronometer & Clock** | `clock_face.dart`, `note_kar_home.dart` | Analog/digital clock face, OpenType tabular figures, live stopwatch chronometer, tick animation, ambient sensor smoothing. |
| **Point-in-Time Logging** | `note_kar_home.dart`, `note_dialog.dart` | Instant 1-tap timestamp capture, single/session modes, hashtag extraction, quick tags carousel. |
| **Contiguous Sessions** | `UniversalIntervalLedger`, `note_kar_home.dart` | Live sessions, boundary resolution, untracked gap detection, claimed gap suppression, smart trim. |
| **Multi-Asset Media** | `MediaStorageService`, `AudioService` | Staged multi-photo capture (up to 5), voice recording with ballistics, pipe-delimited relative paths. |
| **Timeline History** | `history_dialog.dart`, `timeline_session_card.dart` | Continuous chronological stream, calendar day canvas, advanced filters, search, merge, entry deletion. |
| **Goals & Targets** | `goals_sheet.dart`, `GoalsService` | Target allocation across week/month/year/all-time, pacing deficit calculations, 1-tap session start, milestones. |
| **Habit Checkpoints** | `checkpoints_dashboard_screen.dart`, `CheckpointService` | Daily check-in habits, completion streaks, frequency rules, freeze protections. |
| **Sobriety Companion** | `sobriety_companion_settings_page.dart`, `urge_surfing_dialog.dart` | Clean time calculator, milestone badges/shields, urge surfing mindfulness timer, relapse guard. |
| **Stoic Time Reflection** | `time_reflection_sheet.dart`, `time_reflection_settings_page.dart` | Memento Mori weeks-of-life matrix, mortality horizon, stoic reflection prompts. |
| **Life Audit** | `life_audit_page.dart`, `LifeAuditService` | 8-domain wheel-of-life assessment, spider charts, historical comparisons. |
| **Executive Intelligence**| `executive_intelligence_hub_screen.dart` | 24h rhythm distribution, focus tag breakdown, 90-day consistency matrix, weekly trend lines. |
| **Sovereign Encryption** | `VaultEncryptionService`, `data_backup_settings_page.dart` | PBKDF2-SHA256 (100k iter) + AES-256-GCM (.notekar-vault), JSON export, CSV exports, Markdown sync. |
| **Offline Peer Exchange** | `peer_profile_scanner_page.dart`, `peer_profile_detail_sheet.dart` | Encrypted QR profile generation and scanning without cloud servers. |
| **Android RemoteViews** | `NoteKarWidgetProvider`, `SessionWidgetProvider` | 5 home screen widgets with independent background sync and chronometer updates. |
| **Quick Settings Tiles**| `QuickNoteTileService`, `FloatingBubbleTileService` | Instant quick note capture and floating chronometer bubble from Android notification shade. |
| **App Lock & Privacy** | `app_lock_settings_page.dart`, `MainActivity.kt` | Biometric unlock, system PIN, `FLAG_SECURE` recents obfuscation, local network audit log. |
| **Theme Engine** | `palette.dart`, `display_settings_page.dart` | 5 calibrated themes (Light, Dark, AMOLED, E-Ink, Matrix), 7 accent colors, High Contrast mode. |

---

## 4. Protected-Feature Modification Protocol

If an improvement requires modifying any protected subsystem:
1. **Explain the consequence** in `NOTEKAR_IMPROVEMENT_PLAN.md` with explicit justification.
2. **Preserve full backward compatibility** for existing data, schemas, and user workflows.
3. **Obtain explicit user approval** before writing or modifying code.
4. **Run the full test suite** (`flutter test`) and static analysis (`flutter analyze`) to guarantee zero regressions.
