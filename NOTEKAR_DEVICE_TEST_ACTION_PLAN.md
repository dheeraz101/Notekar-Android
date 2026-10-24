# NoteKar Android Device Audit and Gemini Action Plan

**Audit date:** 2026-10-23  
**Build exercised:** 7.5.10 (version code 26101401)  
**Runtime:** Android Studio emulator, Android 17/API 37, `sdk_gphone64_x86_64`, 1080×2424 at 420 dpi  
**Purpose:** Evidence-backed handoff for implementation. This document is not a claim that every Android/OEM/iOS behavior has been verified.

## Handoff rules for Gemini

1. Treat this document as a prioritized implementation backlog, not permission to redesign unrelated areas. Before each item, inspect the named code and current tests; report if the code differs from this audit.
2. Do not invent product rules. For unresolved rules below, propose a minimal user-visible option or ask the owner. Preserve existing data and compatibility.
3. For every fix, name the invariant, change the smallest responsible layer, add/update focused tests, run them, and report commands plus pass/fail. Do not claim emulator verification from unit tests.
4. For UI changes, capture before/after screenshots on the emulator at the documented size. Verify text scaling, screen reader labels, keyboard/insets, back navigation, and empty/error/loading states where relevant.
5. Do not expose real user recovery/profile information in test fixtures, logs, screenshots, widgets, notifications, or backup samples. Use synthetic data.
6. Do not remove “beta” labels or claim platform support until each advertised flow is exercised on supported Android versions/devices. Report any blocked step rather than silently skipping it.
7. Keep this audit file as the implementation checklist; append evidence and mark items complete only after acceptance checks pass.

## Executive summary

The emulator confirmed the core capture/history path works for a small synthetic dataset: two completed two-way sessions generated four moments; History totals and filters reflected the data; search found the saved test note; the annotated-session filter found one session; the Singles filter correctly showed empty for this data; and the active timer survived force-stop/relaunch. A full backup export and same-device import preview showed 4 moments/1 note, 0 new moments, 4 duplicates skipped, and 9 settings offered for restore out of 12 exported. Import was canceled.

In the emulator pass, the biggest confirmed runtime issue was an unhandled Android dynamic-shortcut failure (`PlatformException(quick_action_setshortcutitems_failure, Exception thrown when setting dynamic shortcuts, null, null)`) during startup and after capture. The app remained usable, but the plugin exception’s native cause is not known. Notification permission was denied on that emulator, so its notification delivery was not established. A later physical Android pass is recorded at the end of this document: notification permission was granted there, but actual delivery was intentionally not attempted because the configured message may be user-authored. Widget interaction/resize/restart behavior, app lock lifecycle, and the remaining profile/goals/sobriety flows are still unverified and must not be described as passed. iOS behavior was not tested.

The UI uses iOS-inspired visual language (dark palette, rounded sheets, Cupertino date picker in at least one Android flow), but the requested question is not “does it look exactly like iOS?” Use the [Apple iOS design guidance](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios) as a visual reference while retaining familiar Android system behavior. Avoid asserting “Apple compliant” or iOS equivalent based on this Android emulator.

## What was actually exercised

| Area | Evidence/result | Status |
|---|---|---|
| First run | Welcome onboarding was skipped; Device Health intro continued into the app. | Passed for reachability; onboarding alternatives not exhaustively checked. |
| Capture | Started/ended sessions; tested long-press mode selection (Work/Deep Focus), Add Note and saving “device audit test”. | Passed for these paths. |
| Persistence | Force-stopped/relaunched while a session was active; timer resumed from persisted start time. No `FATAL EXCEPTION` was seen in inspected log output. | Passed narrowly; process death/device reboot/time-zone change still need tests. |
| History | Four moments across two completed sessions and 2 tracked minutes appeared; Work showed 1 minute. `With Notes` showed one; search `audit` found the note; Singles empty state matched two-way-only data. | Passed narrowly; edit/delete/manual entry/merge/media/sort/date-range/filter combinations not fully exercised. |
| Modes | Modes page rendered Work/Deep Focus, Create New Mode, Adaptive Color and Default Mode on App Close controls. New Mode form opened. No custom mode was committed. | Partial. |
| Insights | Habit Checkpoints sheet displayed 0% / 0 of 8 and “Early Rhythm” with no habit logs. | Observed; wording/policy needs product review, not yet classified as a defect. |
| Backup | Full export produced a JSON file in emulator Downloads. Same-file import preview gave coherent dedupe counts; import was canceled. | Partial; no destructive/import mutation test. |
| Notifications | Package permission query: `POST_NOTIFICATIONS` granted=false; app notification importance NONE. | Delivery not tested; currently blocked by permission state. |
| Profile | Profile page opened; synthetic label “Device audit” entered. Save tapped. No real name/date of birth entered. | Setup reachability only; persistence and analytics impact not verified. |
| Goals | Goal creation was completed on emulator; one short session was started/ended, reflection skipped, and goal selection/progress UI revisited. Progress changed to 35m, but existing emulator activity prevents attributing that total solely to the new session. | Partial live verification. |
| Widgets | Five active widget instances verified with `dumpsys appwidget`; Quick Log IN/OUT and Sobriety RESET STREAK actions exercised. Life Audit, minimal sobriety and camera widgets were viewed; camera capture and widget resize/refresh/reboot/accessibility remain unverified. | Partial live verification; see detailed findings below. |
| Sobriety setup, reminders, lock | Sobriety mode remained off; notification permission denied; secure device authentication not configured. | Not verified. |

## Second-pass forensic findings (live emulator session)

These are additional findings from the user-directed follow-up after the first draft. They take precedence over any earlier “not verified” statement below when they describe a flow that was subsequently exercised.

| Finding | Direct evidence | Severity |
|---|---|---|
| Insights opens as an over-height modal sheet rather than a destination page. | Tapping Home → Insights opened Habit Checkpoints in a 90% `showModalBottomSheet` (implementation: `lib/screens/checkpoints_dashboard_screen.dart`, static `show`). The visible sheet clips the Habit Consistency Breakdown at the bottom. Two deliberate long upward drags left the same content at the same position in the emulator screenshot. The hierarchy reports a scrollable area but observed drag did not move it. | P1 usability blocker |
| Habit Checkpoints has duplicate close controls. | Screenshot shows two X buttons in its title bar. The page passes its own `trailingAction` to `AppSheet`, while `lib/dialogs/app_sheet.dart` always adds its own close button. | P2 polish / interaction clarity |
| Sparse habit data is presented as perfect consistency. | The live breakdown showed Waking Up: `1 logs`, `Avg: 11:07 AM`, `±0m variance`, `100%`, and `Stable Routine`; overall card said `1 of 8` habits and `100%`. One data point cannot establish timing consistency. | P1 misleading analytics |
| Accent colors form 6/6/6/2 rows rather than a balanced grid. | `ColorChoiceSetting` in `lib/widgets/settings_widgets.dart` uses `Wrap` and 48×48 logical-pixel circles; the emulator screenshot shows 20 choices laid out 6, 6, 6, 2. Coral selection immediately recolored Home’s accent; blue was selected again afterward. | P2 visual quality |
| “Live Display Preview” is not representative/live. | In Display settings, a preview labeled `Live Display Preview` showed 14:32:48 and `Deep Work Focus`, while emulator time was 11:54 and the app was not in that focus mode; the preview was unchanged in a later capture. Dark → Light applied immediately and Dark was restored. | P2 misleading preview |
| Sobriety widget exposes a destructive-looking reset even when feature is off, and its action writes relapse data. | All five NoteKar widget instances/providers are installed in the emulator launcher. The Sobriety widget showed `Sobriety mode off` alongside active-looking `RESET STREAK` and `ADD DIARY` buttons. Tapping `RESET STREAK` created a new Quick Log/history TAP moment at 11:51:31 tagged `#relapse` and incremented the widget count from 8 to 9, although sobriety remained off. Root cause is confirmed in `SobrietyWidgetProvider.kt`: `widget_single` is bound to a background `single` log with note `#relapse`; `onReceive` writes streak reset prefs without checking `sobrietyEnabled`. | P0 data integrity / sensitive false record |
| Life Audit uses strong moralized wording and needs transparent framing. | Dashboard → Life Audit rendered `Conscious Window: 10.0h / day`, sleep 10h, logistics 4h, focus 33m, void 9h26. With one of seven days present, it displayed `0 DATA AVAILABLE`, `0h Lost`, and said calculations unlock after a full period. Copy describes untracked hours as “lost mortal void.” The zero is consistent with the stated minimum-data rule, but the explanation is visually buried and language can shame users. | P2 product/copy; verify calculation across full period |
| Widgets render and update from their actions, with sizing/privacy review still needed. | Launcher shows Quick Log, Sobriety, Minimal Sobriety, Life Audit, and Instant Camera across two launcher pages. Quick Log IN then OUT updated its latest entry and count (7 → 8); the Sobriety reset action changed it to 9. Camera widget occupied a large area with `No recent photo` and one capture button. | Mixed: basic interaction verified; full parity not yet verified |
| Privacy behavior is reversible on this emulator; secure lock remains untested. | Toggling Hide App Content caused the app screenshot to be black while enabled, then normal content returned after turning it off. App Lock opened a warning that forgetting the passcode could permanently lock data; no PIN was configured, so I canceled before creating a credential. | Partial verification |

### Immediate fixes to add before implementation

1. **Habit Checkpoints destination:** move the dashboard to a proper full-page route (reachable from Home Insights and from History/Settings). Preserve the selected habit and back destination. Retain the iOS-inspired typography, rounded grouped cards, and restrained transitions; keep Android back gestures and page navigation familiar. Remove the redundant close button. If a full-page migration must be staged, first repair the scroll controller/gesture arena and prove all content is reachable, but the preferred product destination is a page, as requested.
2. **Habit statistics:** show “Not enough data” until a documented minimum number of distinct days/logs is met. A single log must never yield “100%” or “Stable Routine.” Show the denominator, period, and how score is computed. Rework the score using a documented time-of-day variance method; ensure its displayed example matches the formula.
3. **Accent picker:** use a responsive five-column grid on standard portrait widths (20 options → four balanced rows), with at least 56dp selection cells and a clear selected outline/check. At narrow widths use four columns instead of clipping or forcing tiny targets. Keep swatches aligned and center the grid. Build a representative preview from actual NoteKar components: home summary capsule, clock/current mode, a real timeline/session card, buttons, selected state, and contrast-aware text; update accent in place. Avoid generic fixed `68%` and “A focused day” data that does not match the user’s state.
4. **Display preview:** either make it truly live (current app time format, active/inactive session state, selected mode, actual typography and accent) or rename it “Example preview.” Recompute seconds only if the user enabled them. Verify preview and actual Home remain synchronized after theme/time-format/seconds/highlight changes.
5. **Sobriety widget safety:** when sobriety is disabled, replace reset and diary controls with one clearly labeled `Set up sobriety` action that opens setup. When active, require an explicit, accessible confirmation before marking a relapse/reset; persist the reset only through the canonical sobriety service, keep a recovery/undo record, and never also create a generic TAP moment unless the user explicitly requested that separate log. Guard receiver actions against disabled state and stale/replayed PendingIntents. Add tests for both widget providers and every state.
6. **Life Audit:** explain the seven-day threshold inline next to disabled/zero metrics; distinguish “not enough data” from a true zero. Replace judgmental “lost mortal void” terminology with neutral, opt-in, user-controlled language (for example, “unclassified time”), and let the user edit sleep/logistics assumptions. Validate day partition sums, horizon labels, per-day versus aggregated semantics, and that synthetic data can produce a nonzero result when the complete window is present.
7. **Widget visual/accessibility pass:** test each widget at minimum/maximum resize, on both launcher pages and in the picker, and ensure live stats use the same source/calculation as the app. Give actions precise labels; avoid vague `RESET STREAK`; hide sensitive sobriety details unless explicitly enabled. Verify Camera empty/loading/permission/error/success states and avoid a large mostly-empty widget by offering a useful compact size.

### Observed dashboard and Life Audit details

The Logging settings page exposed Dashboard and Life Audit. Dashboard opened a tall sheet with Today/Week/Month/All selectors, a story card (“33m ... across 7 moments”), a Life Horizon prompt, and a Life Audit card. Life Audit opened another tall sheet with partition sliders and Today/Week/Month/6 Weeks/6 Months selectors. This proves reachability only: all timeframe selectors and partition-slider persistence were not exhaustively tested. The dashboard narrative must name its date window and data basis; verify it against History totals before relying on it.

### Emulator state created by this second pass

In addition to the earlier synthetic records, Quick Log widget tests created an IN at 11:48:17, OUT at 11:51:19, and the unintended `TAP #relapse` record at 11:51:31. These are visible in History and remain in app data at time of writing; they are synthetic test actions, not the user’s actual activity. Do not delete or reset the full app data to clean them up. The accent was restored to Blue and Display theme to Dark. Hide App Content is off; App Lock remains off; sobriety mode remains off.

Test data remains in emulator app data: two completed sessions, four IN/OUT moments, one note (`device audit test`), approximately two minutes tracked. A full backup and moments JSON also remain under emulator `/sdcard/Download` with filenames `notekar-backup-20261023-112252.json` and `notekar-moments-20261023-112225.json`. No app source files were changed during the audit.

## Findings and ordered actions

### P0 — Resolve unhandled dynamic shortcut exception

**Evidence:** Android logcat repeatedly emitted `PlatformException(quick_action_setshortcutitems_failure, Exception thrown when setting dynamic shortcuts, null, null)` at startup and after logging. Home flow remained usable.  
**Code to inspect:** `lib/screens/note_kar_home.dart`, `_initQuickActions()` near line 991, `_updateDynamicShortcuts()` near line 1033, `quickActions.setShortcutItems(items)` near line 1085; inspect resolved `quick_actions` plugin and Android shortcut limits/manifest configuration.  
**Change:** Await the plugin call inside an explicit error boundary; preserve the main capture flow if shortcut publication fails; log a redacted, rate-limited diagnostic; avoid retry loops; show no false success. Establish native root cause from plugin/native logs instead of guessing.  
**After:** App starts and capture works whether shortcuts publish or not; a supported launcher shows expected shortcuts; unsupported/failure path has no unhandled Flutter exception.  
**Acceptance:** Test startup with normal shortcut list, empty/updated list, repeated updates, force-stop/relaunch, and injected/plugin failure. Confirm no exception leak in Flutter and native logs and inspect launcher shortcuts on emulator plus at least one OEM launcher.

### P1 — Make timeline filters and totals internally consistent

**Evidence from source inspection:** `lib/models/history_timeline_models.dart`, `buildTimelineDataInIsolate`: when `hideCheckpoints` is true, the `else if` structure can skip media handling; filtered day sections can reuse unfiltered counts/totals.  
**Change:** Apply checkpoint/media filters independently, then derive visible rows, counts, durations, and empty state from the same filtered set. Keep section summary semantics explicit (visible versus all records).  
**After:** Every filter combination returns only matching rows and totals that explain those rows.  
**Acceptance:** Add tests for checkpoint-only, media-only, both enabled, neither, mixed days, empty results, and totals after filtering. Verify on History UI that count and duration match visible entries.

### P1 — Align session reconstruction across analytics and handle day boundaries

**Evidence from source inspection:** `lib/services/life_audit_service.dart` (roughly lines 296–340) builds day sections and sums full duration on the IN/start day; a missing OUT can be treated as ongoing without respecting `s.isOngoing`. `UniversalIntervalLedger` stream identity and timeline identity also differ: the ledger key uses goal when present and ignores category, while timeline uses category plus goal. Dashboard uses `UniversalIntervalLedger.reconstructAndSlice`, so analytics may disagree.  
**Change:** Define a single session-pairing key and explicit rules for open/orphan/reversed/cross-midnight intervals. Slice durations across local calendar boundaries consistently; respect persisted ongoing/paused state. Reuse the canonical interval model in dashboard, life audit, History and widgets where feasible.  
**After:** A session crossing midnight contributes the correct portion to each day; malformed pairs are surfaced/ignored consistently rather than silently inflating totals; category/goal cannot cross-pair.  
**Acceptance:** Deterministic tests for midnight/DST/time-zone changes, missing OUT, OUT-before-IN, duplicate IN, same goal/different category, same category/different goal, paused session, and imports with future timestamps. Compare visible dashboard, History, and widget metrics from the same fixture.

### P1 — Unify metric date windows and exclude invalid future rows

**Evidence from source inspection:** `lib/services/dashboard_metrics_service.dart`: tracked slices use calendar Monday week/calendar month (around 267–285), while counts use rolling seven/trailing thirty days (around 483–530); today count has no upper bound and uses `isAfter(todayStart)`, excluding exact midnight while admitting future imports; week/month count windows can also lack an upper bound. `all` appears to use fixed 30-day denominators/pacing around 399–454.  
**Change:** Choose and name each metric’s window (calendar or rolling) in the UI; apply inclusive/exclusive boundaries consistently with a documented local-time/UTC policy; clamp or exclude future records from elapsed-time counts; define “All” as all-time or rename it. Do not change product semantics without updating copy.  
**After:** Same screen cannot show incompatible “this week” values from different window definitions; future-dated imported data cannot create impossible current progress.  
**Acceptance:** Boundary fixtures at exact midnight, Monday/Sunday, month/year transitions, DST, future dates, and timezone changes; compare displayed labels to computed records.

### P1 — Make full backup import faithfully preserve supported fields and report partial failures honestly

**Evidence from source inspection:** `lib/home`/`lib/screens/home/home_backup_lifecycle.dart` export serializes `Moment.toJson()` and settings. `lib/utils/backup_utils.dart` (around 86–95) reconstructs only core fields; merge path in `home_backup_lifecycle.dart` around 326–339 also rebuilds a stripped Moment. Rich fields may include category, tags, image/voice path, duration, goal/project IDs. App-private media paths are not portable to another install. Import writes merged records before sequential SharedPreferences writes; failure text may imply no changes even if records committed. `_saveSetting` ignores SharedPreferences setter boolean results.  
**Change:** Define portable backup contract/version and preserve every supported field. For media, either package attachment bytes with stable relative references and integrity checks, or explicitly omit media with a per-item warning; never restore stale private paths. Validate the whole payload before mutation. Make commit behavior explicit: transaction/rollback if practical, otherwise report which stages completed and provide a recovery/export path. Check preference write results.  
**After:** Import preview predicts actual outcome; restore does not silently discard tags/categories/goal linkage; partial failure message matches persisted state.  
**Acceptance:** Round-trip fixture with notes, tags, categories, goals, media, duplicate IDs, malformed fields, old/new versions, bad attachment hashes, storage failure, and preference write failure. Verify export-import-export semantic equality and idempotence; do not delete data during live-user testing.

### P1 — Make checkpoint session creation atomic and failures visible

**Evidence from source inspection:** `lib/services/checkpoint_service.dart`: `logCheckpointSession` saves IN and OUT separately (around 199/211) despite transactional save support in `MomentRepository.saveMoments` (around 616); sheet catches errors silently (around 235). Checkpoint stats use linear mean/std-dev on clock minutes and one log yields zero deviation/“100” or “Optimal Consistency”; scoring implementation appears inconsistent with its nearby comment.  
**Change:** Save the session pair in one repository transaction; return a typed result; show a recoverable error and do not close sheet on failure. Decide a minimum evidence threshold for consistency labels and use a circular/time-of-day-appropriate statistic or a simpler transparent metric. Align formula comments, score, labels, and copy.  
**After:** A checkpoint either records both endpoints or neither; sparse data is labeled “not enough data,” not optimal.  
**Acceptance:** Inject failure between writes and verify no orphan; test 0/1/2+ days, midnight-adjacent times, duplicate logs, and scoring against documented examples; verify user-facing error and retry.

### P1 — Correct local-backup success signaling

**Evidence from source inspection:** `lib/screens/home/home_backup_lifecycle.dart` quick local backup catches errors and returns void; quick-action flow can show success regardless of persistence.  
**Change:** Return a typed success/failure result and show success only after durable save; display the actual destination/time and actionable retry on failure.  
**Acceptance:** Simulate unwritable/low-storage path; no success toast, no uncaught error, and a successful retry has a verifiable artifact.

### P1 — Establish notification permission, channel, scheduling and action behavior

**Evidence:** This emulator’s app currently has `POST_NOTIFICATIONS` granted=false and notification importance NONE. Android 13+ requires a runtime permission for most notifications; the official Android docs recommend requesting in feature context ([runtime permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission)). Source contains reminder/notification receivers; manifest and channel setup must be checked per flow.  
**Change:** Request permission only after explaining the relevant reminder feature; handle denied/permanently denied states with an in-app status and Settings route; validate channel importance, scheduled time, timezone/DST, cancel/reschedule, reboot restoration, exact-alarm policy if used, action receiver validation, and privacy-safe lock-screen content.  
**After:** User can distinguish disabled permission from no scheduled reminder; reminders don’t duplicate, arrive at wrong local time, or reveal sensitive sobriety/profile notes on lock screen.  
**Acceptance:** Test allow/deny/revoke, app update/restore, channel disabled, Do Not Disturb, timezone/DST, reboot, app force-stop, action tap/dismiss, lock-screen redaction. Record actual delivery timestamps and notification IDs on Android 13+ and target API 37. Do not claim delivery from scheduling-only unit tests.

### P1 — Audit widgets end to end, including sensitive-data privacy

**Evidence:** Manifest registers five Android home-screen widget providers: main Quick Log, Sobriety, Life Audit, Minimal Sobriety, Instant Camera. All five were active on the emulator launcher. Quick Log IN/OUT updated its displayed log count/latest state. A Sobriety widget with sobriety disabled still exposed RESET STREAK; tapping it created a generic TAP moment with `#relapse` and updated streak-related preferences. This is a confirmed sensitive data-integrity bug. Life Audit, minimal sobriety and camera widgets were viewed; camera capture and full size/refresh/reboot/accessibility coverage remain pending. Android describes widgets as actionable, periodically refreshed home-screen elements and calls for sizing/form-factor testing ([Android widget guidance](https://developer.android.com/design/ui/mobile/guides/widgets)).  
**Change:** Test each provider at minimum/maximum supported size, dark/light launcher, refresh/reboot/app update, no data, active session, tap actions, stale data, and accessibility. Confirm sobriety values and last-relapse data are not shown without user intent; add clear per-widget privacy controls if needed. Keep Android app widgets distinct from iOS widgets in claims and implementation.  
**After:** Picker previews match actual widget; every button performs one idempotent action; displayed metrics match app state; sensitive data visibility is deliberate and documented. When sobriety is off, the widget offers setup instead of reset or relapse logging.  
**Acceptance:** Add/remove/resize all five widgets in emulator launcher, tap each action, inspect resulting moments and app navigation, wait/trigger refresh, force-stop/reboot, verify current stats. Repeat on a physical OEM launcher. Capture screenshots.

### P1 — Verify lock, unlock and privacy-lock paths on a secured device

**Evidence from source:** `android/app/src/main/kotlin/app/notekar/notekar/UnlockReceiver.kt` has a quick-note path that starts activity directly; Android background activity launch restrictions may prevent this and a notification fallback exists. `lib/screens/note_kar_home.dart` implements system/custom privacy-lock flows around 4400–4484. Emulator has not been configured with a secure PIN/biometric and no lock-screen flow was confirmed.  
**Change:** Verify each user-facing claim against OS support and privacy settings. Prefer a notification/action that the user taps over direct background activity launch; ensure lock is reapplied after screen off/background/notification shade according to stated policy and sensitive content is hidden in recents/widget/notification.  
**After:** Unlock triggers are predictable, do not bypass secure authentication, and lock behavior matches copy. If a feature is unavailable on this platform/version, state that clearly.  
**Acceptance:** Configure emulator PIN, enable system and custom privacy lock independently, background/foreground, screen off/on, app switcher, notification shade, reboot, wrong PIN, cancel biometric, and quick-note-on-unlock. Verify no activity is launched over lock screen and no private content leaks. Remove test PIN only after verifying lock can be disabled.

### P2 — Make mode and checkpoint preferences survive restart

**Evidence from source inspection:** `CheckpointService.init()` loads persisted presets/hide preference but no initialization call was found in `lib`; `main.dart` startup does not initialize it. `note_kar_home.dart` startup initializes repository/tags around line 832.  
**Change:** Initialize service before dependent widgets render (or inject initialized state); persist custom presets and hide preference reliably; migrate old settings without resetting user choices. Also add mode creation/edit/delete/restart tests because custom mode creation was not committed in runtime audit.  
**After:** Preset list, hidden state, and custom mode behavior remain stable after process death and app upgrade.  
**Acceptance:** Create/rename/delete a synthetic preset and custom mode; toggle hide/adaptive/default behavior; force-stop/relaunch and upgrade fixture; check History/Home/settings agree.

### P2 — Align Android picker and interaction patterns with platform conventions

**Evidence:** Checkpoint session uses `CupertinoDatePicker` on Android (source audit); Modes screen advertises beta; accessibility hierarchy shows several unlabeled icon-only controls on the Modes page. iOS guidelines favor clear primary tasks, adaptive appearance/type, comfortable reach, system gestures and familiar interactions ([Apple iOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios), [accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)).  
**Change:** Keep the iOS-inspired visual style but use an Android-appropriate date/time selection interaction and Android system back/permissions. Give every icon-only action a meaningful semantic label/hint; check touch targets, contrast, font scaling and keyboard navigation. Review “0% / Early Rhythm” with no data and avoid false precision or positive labels that imply evidence. Rewrite copy for clarity and consistency; keep “beta” caveat until verified.  
**After:** Visual language feels cohesive while Android users recognize system behaviors; TalkBack can identify all actions; labels accurately describe evidence.  
**Acceptance:** TalkBack pass on all primary screens, large font/display sizes, contrast checks, landscape/small width, keyboard open/insets, Android back/edge gesture, empty/error/loading screens; screenshot review across light/dark and at least two Android sizes.

### P2 — Make goal calculation semantics explicit and test creation through completion

**Evidence:** `lib/services/goals_service.dart` persists goals in SharedPreferences and calculates progress; tests exist (`test/goals_engine_test.dart`). A synthetic goal was created on emulator, the first save exposed required-field errors, and a short session/reflection-skip flow was completed. The refreshed Home goal card reported 35m tracked, but existing records prevent verifying which entries qualified or whether the aggregate is correct. Edit/archive/delete and boundary behavior remain untested.  
**Change:** Inspect each goal criterion and timeframe in UI and service; verify completion includes only eligible moments, respects start/end boundaries, categories and tags, and recalculates after edits/deletion/import. Prevent stale active-goal references. Ensure empty and over-target states are understandable.  
**After:** Creating a goal, logging a qualifying/nonqualifying moment, and changing date range produces predictable progress and safe undo/edit behavior.  
**Acceptance:** Emulator scenario: create synthetic time/consistency goal; log qualifying + nonqualifying items; cross a day/week boundary with controlled clock or fixtures; edit/archive/restore/delete; restart; inspect Home, goal detail and History. Check existing test coverage and add missing cases.

### P2 — Test sobriety setup, reset and humane language with synthetic data

**Evidence:** Sobriety UI, `SobrietyWidgetProvider`, `MinimalSobrietyWidgetProvider`, service/tests exist (`test/sobriety_and_eos_test.dart`); the live sobriety setup/reset/recovery flow was not exercised.  
**Change:** Verify start date/timezone, reset/relapse semantics, undo/cancel, milestone calculation, pause/disable, backup/restore, reminders, widgets, and delete behavior. Check language for nonjudgmental tone, no medical claims, and explicit consent before public/lock-screen display.  
**After:** Streak is mathematically correct across DST/time-zone/restart; resetting does not destroy history unintentionally; users can recover from accidental input.  
**Acceptance:** Synthetic dates (never use the user’s real recovery data); same-day, leap-day, DST, timezone move, milestone boundary, reset/cancel/undo, restore and widget parity. Confirm no notification/recents leak.

### P2 — Make external automation trust boundaries explicit

**Evidence from source:** `AutomationBroadcastReceiver` is exported without a permission and accepts external input when `flutter.enable_external_automation` is enabled (default false); this may be intentional Tasker interoperability. `ReminderReceiver` is also exported for boot/custom actions.  
**Change:** Document exported action contract, opt-in, caller trust, accepted values, idempotency/rate limits and privacy impact. Validate every field and reject malformed/oversized payloads. Split system boot handling from app-internal actions where possible; do not add a signature permission if it would break intended Tasker clients without a migration plan.  
**After:** Intentional automation continues for consenting users; arbitrary broadcasts cannot create duplicate, malformed or sensitive records.  
**Acceptance:** Instrumentation tests for disabled/enabled, unauthorized/malformed/duplicate/oversized broadcasts, replay, and receiver export flags; verify no PII in logs.

## Focused verification run

Attempted command on 2026-10-23:

```text
flutter test test/goals_engine_test.dart test/sobriety_and_eos_test.dart test/user_profile_personalization_test.dart test/backup_import_test.dart test/life_ledger_timeline_test.dart test/dashboard_metrics_service_test.dart
```

The combined run did not emit output or return an exit code within the observation window and was interrupted. A separate `flutter test test/goals_engine_test.dart` attempt also did not emit output or return an exit code and was interrupted. Therefore all requested test results are **unverified**, not passes. Diagnose the toolchain/test-runner startup or capture its output, then run each target and record exit codes. No app source was altered as part of the audit.

## Completion gate

Do not call this “complete” until the P0/P1 items are resolved or explicitly accepted, focused tests pass, primary real-user journeys are exercised on an emulator with screenshots/log evidence, notifications and all five widgets are tested, lock behavior is verified with a secure screen lock, and a physical Android device pass is recorded. iOS-specific claims require an iOS build/device or simulator; Android appearance is not evidence of iOS behavior.

## Third-pass live emulator findings and coverage boundary (2026-10-23)

This section separates observed behavior from remaining test work. Device: Android 17/API 37 emulator, 1080×2424 at 420 dpi, app 7.5.10. UI hierarchy dumps and screenshots were captured during this session. No source-code changes were made.

### Goal creation and progress: partial end-to-end verification

- Opened History → Targets & Goals → New Goal, entered a synthetic goal titled `AuditGoal`, description `Device audit test`, selected 2h and Weekly, and saved it.
- Pressing Save with title only surfaced both `Goal description is required` and `Target time allocation is required (> 0 hrs)`. The description field is labeled “DESCRIPTION / SCOPE” and its placeholder says “Key deliverables, focus context or notes...” without clearly marking it required; allocation chips also do not make the required initial selection sufficiently clear. Mark required fields and explain the goal's inclusion rules before submission.
- After completing those fields, the goal saved. The goal detail showed 0m tracked, 2h target, 2h remaining, 40m/day needed, 3 days left. Starting and ending a short session led through a Session Reflection screen; Skip returned to Home. The goal selector then showed the goal and a 35m tracked progress card. Because prior emulator records were already present and the short session duration was only seconds, this proves the displayed state refreshes but does **not** establish which historical moments qualified or prove the 35m calculation is correct.
- The created `AuditGoal`, earlier synthetic logging records, and widget test actions remain in emulator data. Preserve them for now; do not bulk-clear history. A future cleanup must identify exact IDs and remove only explicitly synthetic test records with user authorization.

**Action:** Clarify required title/description/allocation, default a sensible target or label it as required, show the goal's period/date range and included category/mode rules, and surface a breakdown of contributing records with tap-through. Validate category-specific, edited, archived, deleted, over-target and period-boundary progress against known synthetic fixtures. The goal page should make `35m of 2h` and the exact contributing sessions understandable rather than giving an unexplained aggregate.

### Live coverage ledger

| Area | Directly exercised this audit | Still not established |
|---|---|---|
| Home and session | Home visible; started/ended a short session; reflection Skip path; home goal selector opened | Every mode, pause/resume, note/tag/photo/voice paths, undo, long-duration and app-kill recovery, full navigation/back stack |
| Insights / Habit Checkpoints | Opened from Home; vertical drag did not move content; content clipped; two close affordances; sparse one-log score appeared as 100% / Stable Routine | Small-screen/font-scale/landscape behavior, all checkpoint create/edit/delete/error cases, corrected full-page behavior |
| History | Prior pass opened History and used filters/actions; test records visible in history | Every filter/sort/date range, edit/delete/undo, attachments, empty/error states, exact reconciliation with dashboard and backup |
| Dashboard / Life Audit | Opened dashboard and Life Audit; inspected Week state, labels and displayed calculation; saw setup prompt | All day/week/month/year/custom selectors, slider persistence, birth-date setup using synthetic date, boundary math cross-check against source records |
| Appearance / accent / display | Changed accent and restored blue; tested dark/light and restored dark; observed 20-color 6/6/6/2 layout and static preview mismatch | Every theme/accessibility setting, all colors, system appearance integration, font scaling and narrow-width layout |
| Profile / privacy | Profile setup was attempted in earlier pass; Hide App Content on/off changed screenshots; App Lock warning inspected and canceled | Profile persistence after restart, secure PIN/biometric setup, complete lock/unlock lifecycle, screenshot/recents/notification policy in all app states |
| Goals | Created synthetic goal; validation errors; session/reflection/skip; revisited goal selector/progress | Qualification correctness, goal edit/archive/delete, checkpoints/milestones, timeframe boundaries, restart/backup parity |
| Sobriety | Sobriety-off state viewed; disabled widget's RESET STREAK action tapped and false relapse record confirmed | Enable/start/reset/cancel/undo, milestones, timezone/DST, recovery, notifications, privacy after setup |
| Widgets | All five providers active; Quick Log IN/OUT and Sobriety reset tapped; Life Audit/minimal/camera surfaces viewed | Camera capture; resize extremes; refresh after restart/reboot; TalkBack; duplicate/replay taps; permission/state edge cases; physical launcher |
| Notifications | Permission state inspected and found denied | Permission grant/denial UX, schedule/delivery/actions/cancel/reboot/timezone/lock-screen privacy |
| Remaining Settings | Privacy, Appearance, Display/Accent and Logging→Dashboard entry explored | Every settings page and each switch/button response; search and inventory all settings destinations before claiming completion |

### Mandatory method for the remaining audit

1. Inventory all navigable routes and settings controls from the running app plus source; create one row per screen and one row per interactive setting/action.
2. For each row, record precondition, exact user action, expected state change, observed state change, screenshot/hierarchy evidence, persistence after back/relaunch where relevant, and status (`pass`, `fail`, `blocked`, `not run`). Never turn `not run` into a pass based on code presence.
3. Use only clearly labeled synthetic records for destructive/reset flows. Before/after compare the exact target item or setting; avoid broad clear-data operations.
4. Test primary journeys from a fresh launch and from realistic existing data, covering empty, populated, invalid, permission-denied, offline/error, and restart states where applicable.
5. Review iOS-inspired styling as a visual language while validating native Android navigation, permission prompts, widgets and system surfaces separately. Do not call an Android emulator an iOS review.
6. Prioritize the confirmed disabled-sobriety widget mutation as P0, then Insights navigation/scroll/accessibility, data-meaning correctness, and safety/privacy; assign confidence and evidence to each recommendation.

The user correctly identified the Insights issue and the accent-grid weakness. The previous audit was incomplete because it did not systematically exercise each real screen and response, and it overstated code/source review as a substitute for device evidence. The coverage table above is the current honest boundary; the app is **not yet fully audited**.

## Final UX/UI audit synthesis — ranked changes and target experience

This is a UX/UI improvement brief, not a claim that every route, state, accessibility mode, or physical device has now been tested. Direct observations are identified as such; broader requirements below are design recommendations to validate during implementation. Preserve the restrained typography, dark canvas, rounded surfaces, blue accent, and quiet clock-led identity. Improve clarity and platform behavior without making the app look like a generic Material template.

### P0 — Stop a disabled feature from writing sensitive history

**Observed:** Sobriety was off, but its widget still showed `RESET STREAK`; tapping it created a `#relapse` TAP record. The user did not enable that feature or ask to log a relapse.  
**Change:** When disabled, replace every action on the sobriety widget with a single `Set up sobriety` action that opens the relevant in-app setup. When enabled, replace destructive-looking shortcut behavior with a clearly labeled `Log a lapse` action, explicit confirmation, correct domain event (not a generic TAP moment), and undo. Recheck feature state at action receipt so stale widgets/PendingIntents cannot mutate state after disable/reset.  
**After:** Disabled widget shows a neutral setup card with no streak/reset/relapse controls; enabled controls describe the actual outcome. The home screen, widget, and History all agree after one action.

### P1 — Give Habit Checkpoints its own navigable page

**Observed:** Home → Insights opens `Habit Checkpoints` as a 90%-height modal. Content clipped at the bottom and vertical drags did not move it; there are duplicate X controls. One logged routine rendered `100%`, `Stable Routine`, despite only `1 of 8` habits tracked.  
**Change:** Open it as a full-height route/page from Home and History, with one standard back affordance and one page title. Use a normal page scroll view whose scrollable region reaches below the final card and above safe-area navigation. Remove the page-specific trailing close because `AppSheet` already provides one if this remains temporarily sheet-presented. Define an evidence threshold: with too few distinct days/logs, show `Not enough history yet` and the exact number of observations needed; never classify a single observation as stable or 100% consistent.  
**After:** Tapping Insights lands on a dedicated page, all sections scroll to the end, Android Back returns to the exact source screen, and sparse data explains how to build a useful trend without overstating confidence.

Apple’s current guidance says sheets are for scoped, brief tasks and recommends alternatives for complex/prolonged flows; it also cautions against using a sheet to navigate app content. Apply that principle to Insights, History, Dashboard, and multi-page Settings while retaining sheets for short choices and confirmations ([Apple HIG: Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [Apple HIG: Modality](https://developer.apple.com/design/human-interface-guidelines/modality)).

### P1 — Replace the decorative Display sample with a truthful preview

**Observed:** On the physical Realme RMX3388 (Android 13) and the emulator, the page labeled `Live Display Preview` showed a fixed sample time/mode that did not match the device/app state. Source hard-codes those values in `lib/dialogs/settings/display_settings_page.dart` around 601 and 716.  
**Change:** Render the same clock widget/component and mode state used on Home. Bind it to `DateTime.now()`, selected time format, seconds/highlight settings, chosen font, accent, theme, and the actual selected/default mode. If a faithful live rendering is too expensive, label it `Example` and use representative values that visibly read as illustrative; do not call fixed sample content live. Add a small note that explains which settings are reflected.  
**After:** Changing time format, theme, seconds, font or accent immediately changes a preview that resembles the actual clock and mode chip. No fictitious live state is presented.

### P1 — Rebuild Accent Color selection as a balanced, accessible palette

**Observed:** The 20 options rendered as 6/6/6/2 rows on the emulator, but as 5 columns × 4 rows on the physical Realme RMX3388 at 480 dpi. The layout is width-dependent; five per row is already achieved on this physical device. Swatches are 48dp, and the accessibility nodes do not report a selected/checked state.  
**Change:** Keep the successful 5-column × 4-row result on the tested physical width and define explicit responsive breakpoints (including a tested narrow width); do not force five columns where they clip. Keep at least a 48dp hit region around each swatch (56dp visual cell preferred if it fits). Align every circle and its selected indicator to one grid. Add a text name and selected-state semantic label; do not rely on color alone. Keep a single `Preview` showing the real Home clock, top summary, mode pill, and a representative History row so color contrast is checked on actual surfaces, not only a line/button/pill.  
**After:** All swatches align in a deliberate grid; each selection has a visible check plus a spoken color name; preview demonstrates where the accent appears in normal use.

### P1 — Make goal setup understandable before Save

**Observed:** A synthetic goal could not save until both description and allocation were supplied. The form did not clearly say either was required, and the horizontal allocation list exposed a clipped final chip. After save, goal detail showed a useful target and pace, but the Home selector later displayed an unexplained aggregate (`35m tracked`) that could not be reconciled because prior records existed.  
**Change:** Decide whether Description is truly required. If it is, mark `Description *` and describe the minimum useful content; if not, remove that validation. Default a reasonable target or mark `Target hours *` and keep Save disabled with inline help until selected. Keep chip widths fully visible or add a clear horizontal-scroll affordance and a custom-number option. Make Save/Cancel sticky above the keyboard and safe area. On the detail page show period dates, selected categories/modes, target, counted time, and a tap-through list of included records; say why a record did not count.  
**After:** The form communicates what is needed before submission, never hides validation behind a Save attempt, and users can inspect exactly how progress was calculated.

### P1 — Clarify Home’s primary action without losing its calm clock identity

**Observed:** Home dedicates most of the viewport to a centered clock and has large areas of empty space. The action target is visually the clock/background, while gestures (tap, double-tap, hold, horizontal swipe) carry different actions. The app’s own accessibility label describes these gestures, but the visible screen has little persistent instruction once the first-use coachmark is gone.  
**Change:** Keep the large clock, but give the current state a compact visible instruction near it or just above the bottom controls: e.g. idle `Tap to start • Double-tap to log a moment • Hold to add a note`; active `Tap to finish • Hold to add a note`. Ensure exact wording is derived from the selected mode and does not claim a gesture that mode does not support. Provide an optional recent-moment/goal summary in a small collapsed card, not a permanent dashboard competing with the clock.  
**After:** First-time and returning users can tell what a tap will do and what state they are in, while the clock remains the visual focus. Test with one-hand reach and large text; do not solve empty space by adding unrelated metrics.

### P1 — Make Dashboard and Life Audit metrics explainable and humane

**Observed:** Dashboard narrative and Life Audit present derived time partitions and currently use terms such as `Void`, `lost`, and `wasted` time. The Week view showed zero available data and said the period unlocks after more logging, but the relationship between the selected date range, observed days, and calculated totals was not prominent.  
**Change:** Put period and coverage directly beside the summary (`Week of … · 1 of 7 days with data`). Add a `How this is calculated` expansion for conscious window, sleep, logistics, focus and unrecorded time; distinguish recorded facts from estimates. Prefer neutral labels such as `Untracked time` and `Time outside logged activities`; avoid moral judgment and show uncertainty. For no/low data, explain the next useful action rather than presenting a zero score as a verdict.  
**After:** People can understand where each number came from, what is incomplete, and how to interpret it without feeling blamed. Reconcile totals with History for the same period before release.

### P2 — Improve Settings navigation and information scent

**Observed:** Settings is a nearly full-screen modal sheet with search, a large profile card, and grouped entries; pages such as Personalization are pushed inside that sheet. This works visually but makes a long settings hierarchy feel like an app nested inside a modal and leaves less content height for long controls.  
**Change:** Promote the Settings root and major destinations (Profile, Appearance, Logging, Privacy, Reminders, Data & Backup) to full-page routes with a stable title/back path. Keep compact pickers and confirmations as sheets. Keep search visible or easily reachable and show categorized results with destination labels; remove oversized summary cards that displace frequently used controls. One modal at a time; never stack settings sheets over other sheets.  
**After:** Settings has a clear navigation path and full usable viewport; Android Back and gesture navigation behave predictably; short actions still use the familiar rounded sheet language.

### P2 — Improve History filter discoverability

**Observed:** On the 1080px emulator, History’s horizontally scrolling filter row displayed `All`, `Sessions`, `Singles`, and `With Notes`, with `Checkpoints` only partially visible behind the edge/scroll-to-top control.  
**Change:** Keep the most common filters visible and provide a labeled `More filters` control or an obvious edge fade/scroll hint. When scrolled, show selected filters and a one-tap `Clear`; keep the scroll-to-top action from overlapping the filter hit area. Ensure active filter state remains visible while scrolling the timeline.  
**After:** Users can discover Checkpoints and other filters without accidental horizontal gestures, see which filter is active, and never tap an overlapping control.

### P2 — Calibrate contrast and component density across all themes

**Source-based risk to verify:** Dark palette clock color is `#5A5A5E` on black; AMOLED palette clock color is `#48484A` on black (`lib/models/palette.dart` around 199). The latter is approximately 2.3:1 contrast, below the 3:1 minimum for large text in WCAG 2.2 SC 1.4.3. The live screenshot shows the low-luminance clock styling prominently. This is a source-derived contrast calculation, not a full rendered contrast audit or a claim that WCAG formally governs every native UI element ([W3C WCAG 2.2](https://www.w3.org/TR/WCAG/)).  
**Change:** Run automated contrast checks on every foreground/background token pair in Light, Dark, AMOLED, Matrix, E-ink and high-contrast modes. Raise large essential clock contrast to at least 3:1 and normal-sized helper text to 4.5:1 where WCAG applies; retain muted hierarchy with size/weight/spacing instead of opacity alone. Check focus, disabled, selected and error states.  
**After:** Clock, button labels, selected states and helper text remain readable in every theme and high-contrast mode, with color not carrying meaning by itself.

### P2 — Polish modal and card hierarchy consistently

**Observed:** Settings and History use a rounded modal container with drag handle and top-right X; some nested screens add back plus X, while the Insights page supplied another X in addition to the sheet close. Cards and segmented controls are visually large and heavily rounded, producing a consistent but sometimes dense/oversized presentation.  
**Change:** Define one navigation rule: full page = one back button; temporary sheet = one close/cancel; multi-step sheet = back plus explicit cancel/save only where meaningful. Use one spacing/radius/typography scale and align headings/control heights. Reserve the strongest surface and accent for the current selection/primary action; reduce duplicate outlines and oversized icon tiles when they compete with labels.  
**After:** Each screen has one obvious exit path and one obvious primary action; the same components feel related without every element competing at maximum size.

### Cross-screen acceptance criteria for the UI work

- Record screenshots at default and largest supported text size, narrow device width, landscape, Light/Dark/AMOLED, and with the keyboard visible. Fix clipping before visual polish is accepted.
- Measure contrast for actual rendered color pairs; test TalkBack labels/focus order and touch targets. A screenshot alone does not prove accessibility.
- For each key journey (start/stop/log, History inspect/edit, create goal, Insights, Life Audit, theme/accent, privacy, reminders, widget action), record expected result, actual result, screenshot, and state before/after.
- Treat design recommendations as hypotheses when they depend on preference (for example, whether users want the optional Home summary); validate with a short task test rather than silently adding more dashboard density.
- Keep the iOS-inspired visual craft, but use Android platform navigation, permission prompts, widget layouts, and system behaviors. Apple HIG and Android widget guidance inform these recommendations ([Android widget quality and sizing](https://developer.android.com/design/ui/mobile/guides/widgets)).

## Physical Android device pass — 2026-10-23

**Device/build:** Realme RMX3388, Android 13/API 33, 1080×2400 at 480 dpi; NoteKar 7.5.10 (26101401). All actions targeted USB serial `5PBECM8DLRLJMVT4`; the connected emulator was not used for these observations. The device contained existing user profile, history and active sobriety data. Those records were treated as real; no profile, sobriety, history, mode, tag, or theme data was reset or deleted.

### Direct physical observations

- **Settings routes exercised:** Settings root, Appearance/Accent, Display, Logging, Dashboard, Life Audit, Capture, Moments, Modes (new-mode dialog opened then canceled), Activity Tags (add-tag dialog opened then canceled), Reminders, Privacy & Security/App Lock information sheet, Advanced/Accessibility. This does not cover every destination or every control.
- **Accent picker:** 20 swatches render 5 × 4 on this physical phone; this differs from the emulator’s 6/6/6/2 layout. Swatches expose their color names to UIAutomator but not selected/checked state. The preview is still a generic sample, not representative of real Home/History states.
- **Display preview:** Its clock/mode sample is static and does not match the real device state. Seconds/highlight controls are exposed as generic clickable views without a checkable state. Existing display settings were not changed.
- **Life Audit:** The `6 Months` timeframe chip is clipped at the right edge on this phone. The page uses shame-heavy copy including `lost mortal void` and `Critical Life Void`. Sliders were inspected but not moved. Full lower-page scroll/calc reconciliation was not completed.
- **Activity Tags:** The add form’s glyph options visually render as the same generic tag icon. Source confirms Cupertino code points are passed into a Material-icon lookup whose unknown values fall back to `Icons.label_rounded` (`lib/dialogs/settings/activity_tags_settings_page.dart`, `lib/models/activity_tag.dart`). The form was canceled without saving. Text and glyph controls were not present in the captured UIAutomator semantics tree; verify with TalkBack on-device.
- **Capture:** `Note on Click` was toggled on and immediately off; its initial off appearance was restored. The control does not expose a checkable state in UIAutomator. Other Capture/Moments/Modes toggles were inspected but not systematically activated.
- **Reminders:** Android notification permission is granted. Daily Reminder began off; temporarily enabling it revealed a default 21:00 time and a configured message. It was turned off and its original default time/message were not edited. A delivery test was not completed because the configured message could be user-authored, and a real notification would expose it; do not claim notification delivery. Mindfulness remained disabled; inactivity and weekly reminders were not changed.
- **App lock:** App Lock reports Off. Its information sheet says it uses device biometric/system PIN. The sheet was inspected; no credential was entered and lock was not enabled. Real lock/unlock remains unverified.
- **Large Text:** The in-app Large Text control was toggled for a visual check and returned to its observed starting appearance (off). While the UI switch visibly changed, its semantics node continued to report `checked=false`; accessible state is therefore unreliable. OS font scale remained 1.0; the attempted system setting change was denied by Android and did not persist.
- **Widgets:** Android reports five NoteKar widget instances in the launcher host, covering Sobriety (two instances), NoteKar, Life Audit and Instant Camera providers; all five provider types are registered. This confirms installed/placed instances, not visual correctness, tap behavior, resize, or refresh. No launcher layout was rearranged, no widget action was invoked, and no camera photo was taken.
- **Permissions:** Notification and camera permissions are granted. Permission-denial and revocation recovery were not tested.

### Physical pass coverage and remaining gates

| Area | Physical result | Remaining evidence required |
|---|---|---|
| Settings | Major routes above opened; selected controls tapped and restored | Inventory every route/control, expected result, actual result, persistence/relaunch |
| Goals/checkpoints/calculations | No user data changed; existing data cannot serve as a known fixture | Isolated synthetic fixture or deterministic service tests; reconcile exact contributing records across Home, History, Dashboard and Life Audit |
| Accessibility | TalkBack enabled then disabled; Large Text visually exercised/restored | Human listening/focus-order audit; verify all controls expose role/value/selected state; OS large text, switch access and keyboard |
| Layout | 1080×2400 portrait only; Life Audit chip clipping reproduced | Narrow width, landscape, keyboard-open and largest supported OS font scale |
| Sobriety/profile | Existing real profile/sobriety left untouched | Synthetic account/data lifecycle, persistence after restart, reset/undo and permission recovery |
| Notifications | Permission and reminder configuration UI checked; no delivery claimed | Generic test message, actual delivery, tap action, cancel, reboot, time-zone and lock-screen privacy on a safe test profile |
| Widgets/camera | Five registered provider types; five launcher instances observed | Per-widget visual/action/resize/restart/refresh/privacy test; camera launch plus synthetic blank-scene capture and cleanup |
| Security | App Lock is off; information sheet inspected only | Credential-authorized setup, biometric/PIN success/failure, recents/screenshot privacy and disable/recovery paths |

A focused `flutter test test/goals_engine_test.dart` attempt produced no output for roughly 40 seconds and was interrupted; it is **inconclusive**, not a pass or a test failure. No known-data calculation is certified by this pass. No app source files were changed.

The temporary screen-awake override used during this session was cleared before ending the pass (`adb shell svc power stayon false`). Never change font scale, launcher layout, real profile/sobriety data, custom content, or app lock state without a reversible plan and a verified restoration.

## UI/UX implementation progress — 2026-10-23

Implemented a first UI-focused change set in the Flutter project:

- Habit Checkpoints now opens as a full-screen route with a normal app bar and vertically scrollable content, replacing the clipped, non-scrolling modal presentation observed during the device pass.
- Life Audit timeframe choices wrap onto additional lines with minimum 44 dp controls and selected-state semantics. The visible summary language and colors now describe tracked/untracked time neutrally; the optional horizon is explicitly labeled illustrative and not a prediction.
- Accent choices use a responsive grid capped at five columns, larger swatches, and accessible selected-state labels. Its sample is identified as an example and reflects the current device time.
- Display preview uses the current local time, honors the selected clock format/seconds/highlight/font options, and labels the displayed mode from the active/default mode.
- Activity Tag glyph choices now use distinct Material glyphs that resolve correctly in the app, with larger targets and labels for assistive technology.
- Settings switches expose their value/enabled state and action hint through semantics. Home shows a short mode-aware gesture hint. Goal names allow up to 40 characters, description/allocation required fields are clearer, and target-allocation presets wrap rather than clipping.
- Related Life Audit dashboard/share copy was softened; updated English source strings have translations in the existing supported languages where added in `l10n_utils.dart`.

### Not yet established

- These source changes have **not** been rebuilt, run through automated tests, or rechecked on the physical phone. The earlier device observations remain the evidence for the pre-change behavior; do not treat the UI fixes as device-verified.
- Large text, TalkBack focus order and spoken labels, landscape/narrow layouts, keyboard-open layout, and theme contrast still require direct verification.
- Some UI recommendations in the audit remain unimplemented, including complete History filter discoverability, full Settings route/control inventory and exit-path consistency, visual contrast measurement across every theme, and real widget interaction/resizing/restart checks.
- Next phase after the UI pass: verify and correct calculations and state behavior for goals, checkpoints, Dashboard, Life Audit, History, sobriety, profile persistence, notifications, widgets, and camera flows using safe known data. Keep the user’s existing records intact.



## Follow-up UI audit — 2026-10-23

History filter discoverability, the Settings destination/control source inventory, and narrow/large-text plus keyboard-open emulator observations are documented in [NOTEKAR_UI_REMAINING_REVIEW.md](NOTEKAR_UI_REMAINING_REVIEW.md). Landscape remained unverified, and source changes remain unbuilt because Flutter analysis and a debug APK build both stalled without output. The History strip now has three primary filters and a fixed More filters control; this change still needs a successful build and device retest.
