---
description: Mandatory standards for 60/120fps frame rendering, widget rebuild optimization, and battery efficiency
globs: lib/screens/**/*.dart, lib/widgets/**/*.dart, lib/controllers/**/*.dart, android/app/**/*.kt
---

# 07 - Performance & Battery Efficiency Standard

## 1. Frame Budget (60fps / 120fps)
- UI interactions, list scrolls, and bottom sheet expansions must maintain 60fps (or 120fps on high-refresh displays) without frame drops (jank).
- Build methods must remain pure, synchronous, and lightweight. Never perform disk I/O, database queries, or expensive cryptographic hashing inside `build()`.

## 2. Widget Rebuild Minimization
- **Use `const` Constructors**: Mark stateless widgets and static token decorations as `const` wherever possible.
- **Localized State**: Use granular `ValueListenableBuilder`, `ChangeNotifier`, or sub-widget extraction instead of triggering full-screen `setState()` at the page root.
- **ListView Optimization**:
  - Always use `ListView.builder` or `CustomScrollView` with `SliverList` for timelines, history feeds, and tag lists.
  - Provide an explicit `itemExtent` or `prototypeItem` when item heights are uniform.

## 3. Battery & Wake Lock Guidelines
- Native background services (`FloatingTimerService`, `DigitalWellbeingManager`) must avoid holding CPU `PARTIAL_WAKE_LOCK` unnecessarily.
- Debounce rapid sensor events (accelerometer, step counts) using appropriate sampling intervals (e.g. 500ms throttling).
- In chronometers and live timers, avoid sub-millisecond redraw loops. Ticking at 1Hz (or 10Hz if showing tenths) is optimal for battery preservation.

## 4. Memory Leak Prevention
- Always dispose `AnimationController`, `TextEditingController`, `ScrollController`, and `StreamSubscription` in `dispose()`.
- Clear cached bitmap images when navigating away from photo lightboxes.
