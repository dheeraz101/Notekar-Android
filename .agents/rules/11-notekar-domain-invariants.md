---
description: Mandatory repository domain invariants consolidating all hard-won production lessons and guardrails
globs: **/*.dart, android/app/**/*.kt, **/*.kts, **/*.xml
---

# 11 - NoteKar Domain Invariants & Production Guardrails

This document codifies the 11 critical architectural invariants established through production releases of NoteKar.

---

## 1. Android & Flutter SharedPreferences Type Guardrail
- **String Lists as Sets**: Flutter stores `List<String>` in Android SharedPreferences as a `Set<String>`. In Kotlin code, always access these using `getStringSet(key, null)` or inspect both JSON string format and `getStringSet` safely with try-catch.
- **Channel-Based Explicit State**: For critical native UI components (app widgets, quick actions, persistent notifications), prefer pushing synchronized state via `MethodChannel` payloads in addition to reading passive SharedPreferences.

---

## 2. Background Log Session Mode Invariance
- **Active Category Propagation**: When an `in` session entry arrives with a non-null, non-'All' category in `_syncBackgroundLogs()`, `_activeCategory` must be immediately updated to match that category before pushing state back to native Android. Never send a stale `'All'` fallback while an active session is running in a specific category.
- **Lifecycle Reset Guards**: Preferences such as `m-reset-mode-on-close` must strictly be guarded by `_sessionStart == null`. Never reset the active category if a live session is currently in progress.
- **Synchronous Native Write on Start**: When `QuickNoteActivity` or `NoteKarWidgetProvider` initiates a session in a selected category, it must synchronously write that category to both `widgetPrefs` and `flutterPrefs` before dispatching `notifyBackgroundLogRecorded()`.

---

## 3. Timeline Session Lifecycle, Gap Consumption, and Boundary Invariants
- **Stateful Boundary Pairing Across Contiguous Sessions**:
  - Contiguous session boundaries occur when Session A ends at timestamp $T$ (`out`) and Session B starts at timestamp $T$ (`in`).
  - If an active unclosed session started prior to $T$ (`activeIn != null`), the `out` at timestamp $T$ closes that preceding session. The `in` at timestamp $T$ then opens the subsequent session.
  - If no session is active prior to $T$, simultaneous `in` and `out` moments at timestamp $T$ pair together into a single completed session.
  - Leftover `out` moments without preceding `in` moments degrade cleanly into `TimelineSingleItem` point-in-time logs.
- **Untracked Gap Consumption and Session Exclusivity**:
  - Any manual entry seeded from an untracked gap must strictly produce a completed session (`lockToSession: true` / `_isSession = true`), never a single point-in-time log.
  - Claiming Rest or logging a manual session immediately claims the interval (`claimedGaps.add('$startMs-$endMs')`), suppressing the gap card optimistically in both Normal (Timeline) and Calendar (Day Canvas) views.
- **Live Session Termination**:
  - Ending an active live session (`_endLiveSession`) must never abort due to downstream moments. It calculates an authoritative effective timestamp, inserts the terminal `out` moment, and notifies the root state handler.
  - Guard rapid multi-taps on "End" with `_isEndingLiveSession`.
  - Calendar view parity: Any session with `isOngoing == true` must render the live visual indicator (`LIVE`) and provide the "End" session control identical to the standard timeline.

---

## 4. Multi-Media Attachment Invariance & Lifecycle Guardrails
- **Non-Destructive Staging & Editing**:
  - Note editing dialogs (`NoteDialog`, `BigNoteDialog`, `QuickNoteActivity`) must never treat media as single scalar fields that clobber existing assets.
  - Recording an additional voice note or attaching an additional photo must append to the staged list, not replace prior items.
  - Removal of a single attachment must only unlink that specific item, leaving remaining attachments intact.
- **Path Invariance & Relative Resolution**:
  - Media paths stored in database entities (`Moment`) or native JSON payloads must strictly use invariant relative paths (`images/img_<timestamp>_<random>.jpg`, `voice/voice_<timestamp>_<random>.m4a`).
  - Store multiple paths delimited by pipe `|` (`images/a.jpg|images/b.jpg`).
  - Never persist absolute Android sandbox paths (`/data/user/0/...`).
- **Cascade Purging & Caps**:
  - Permanent purge from trash iterates through all linked image and voice assets.
  - Soft-delete (moving to trash) never deletes media files from disk.
  - Enforce maximum cap (default 5 photos, 5 voice notes) per moment.

---

## 5. Notification Action & Quick Action Uniformity
- **Action Label Brevity**: Notification action titles must never exceed 8 characters (e.g. `📝 Log`, `🏷️ Modes`, `▶ Start`, `⏹ OUT`).
- **Semantic Separation**:
  - `Log`: Universally opens fast point-in-time note capture (`EXTRA_LOG_TYPE = "single"`, `EXTRA_IS_SESSION = false`).
  - `Modes`: Opens mode/category/goal configuration. When in Two-Way standby, Modes leads exclusively to starting a session (`▶ Start`).
- **Cap**: Maximum 3 `addAction()` intents per notification builder state.

---

## 6. RemoteViews Background State Sync
- When home screen widgets trigger background actions while Flutter is suspended or killed, the native receiver must update both `FlutterSharedPreferences` AND `widgetPrefs`, and invoke `updateAllWidgets(context)` immediately.
- RemoteViews UI and chronometers must never freeze waiting for Flutter isolate wakeup.

---

## 7. Notification Small Icons Invariant
- Status bar and lockscreen notifications must always use flat monochrome vector assets (`R.drawable.ic_stat_notekar`).
- Never use `R.mipmap.*` adaptive launcher icons for `NotificationCompat.Builder.setSmallIcon()`.

---

## 8. CI & Gradle Build Resilience
- **CodeQL Toolcache Pinning**: Pin `github/codeql-action/init` and `analyze` to compatible versions (`@v4.39.1`) with `tools: linked`.
- **Gradle Wrapper Pre-Provisioning**: Pre-provision the `-bin.zip` wrapper in `$HOME/.gradle/wrapper/dists/...` with `curl -f -L --retry 3` using high-speed CDN mirrors (Tencent Cloud / Huawei Cloud).
- **Large Binary Pre-Caching**: Pre-cache large artifacts (such as `kotlin-compiler-embeddable`) directly into Gradle cache.
- **Composite Build Guard**: Never inject `allprojects { repositories { ... } }` into `$HOME/.gradle/init.d/` init scripts if the build includes composite projects.

---

## 9. Flutter ByteData Buffer Slicing Invariant
- Never call `byteData.buffer.asUint8List()` without arguments.
- Always pass slice offsets:
  ```dart
  final uint8List = byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
  ```

---

## 10. Database Engine Migration Safety
- Never assume fresh state. Existing users will have databases on disk from earlier versions.
- Inspect legacy database files and secure storage keys before initializing empty stores.
- Migrate entities inside a verified transaction and synchronize auto-increment IDs.
- Guard migration routines with dedicated persistent version flags (e.g. `legacy_migrated_v2`).

---

## 11. Edge Swipe Non-Contention (Predictive Back)
- Custom edge drag gesture recognizers (`PredictiveBackPeek`) must filter pointers in `addAllowedPointer()` before entering the gesture arena (`details.localPosition.dx <= edgeWidth`), allowing child horizontal scrollables (carousels, docks) to claim drag events seamlessly without arena contention.
