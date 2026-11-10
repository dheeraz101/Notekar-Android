---
name: perf-analyze
description: Profile frame rendering rates, list scrolling, widget rebuilds, and native Android battery consumption on NoteKar.
---

# Performance & Battery Analysis

Execute the performance analysis workflow for NoteKar:

1. Follow all steps in [.agents/workflows/06-performance-analysis.md](file:///.agents/workflows/06-performance-analysis.md).
2. Inspect widget rebuild scopes; ensure `const` constructors on static nodes.
3. Verify `ListView.builder` caching and thumbnail dimension constraints.
4. Run in profile mode on connected device/AVD: `flutter run --profile`.
5. Audit frame timing (< 16.6ms for 60fps) in Flutter DevTools.
6. Audit native Android wake locks in `FloatingTimerService.kt`.
