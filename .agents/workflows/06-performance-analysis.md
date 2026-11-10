# Workflow 06: Performance & Battery Analysis

> **Command**: `/perf-analyze`  
> **Objective**: Profile frame rendering rates, widget rebuild overhead, memory allocations, and native background battery consumption.

---

## 1. Preconditions
- Android device or AVD (`Pixel_10a`) running, connected via ADB:
  ```powershell
  adb devices
  ```
- Flutter profile build available or executable in profile mode.

---

## 2. Profiling Steps

### Step 1: Widget Rebuild & Tree Depth Audit
1. Inspect main screen widgets (`note_kar_home.dart`, `timeline_session_card.dart`).
2. Identify widgets calling `setState()` at the parent level instead of granular leaves.
3. Check for non-const constructors in static layouts and replace with `const`.

### Step 2: List Scrolling & Memory Paging Audit
1. Verify timelines and feeds use `ListView.builder` with `cacheExtent` tuned to 2 screens maximum.
2. Confirm image thumbnails use cached dimensions (`memCacheWidth` / `memCacheHeight`) to prevent full-resolution bitmaps from filling the Dart heap.
3. Check for unbounded stream listeners or missing controller disposals.

### Step 3: Frame Timing & Jank Inspection (Android Profile Mode)
1. Run application in profile mode:
   ```powershell
   flutter run --profile
   ```
2. Open Flutter DevTools:
   - Check Timeline view for frame rendering times (target: < 16.6ms for 60fps, < 8.3ms for 120fps).
   - Flag any frames exceeding the budget (jank).

### Step 4: Native Android Battery & Background Wake-Lock Audit
1. Inspect `FloatingTimerService.kt`:
   - Verify `wakeLock.acquire(timeout)` has a strict safety timeout.
   - Confirm wake lock is released immediately when timer is paused or stopped.
2. Check AlarmManager alarms:
   - Ensure alarms use `setAndAllowWhileIdle()` or `setExactAndAllowWhileIdle()` only for critical reminders, not continuous polling.

---

## 3. Safeguards
- Never disable hardware acceleration or GPU compositing.
- Never strip error handling or null checks in the name of micro-optimizations.

---

## 4. Completion Criteria
- Frame times within 16.6ms budget.
- Zero memory leaks detected on controller disposals.
- Native background services release all resources promptly.
