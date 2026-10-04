---
name: phase4-dependencies
description: Allows the addition of specific structural dependencies required for Phase 4 upgrades.
---

# Phase 4 Dependency Override

While early phases of NoteKar strictly forbade new dependencies to keep the architecture clean (relying only on ListenableBuilder, Hive, etc.), Phase 4 Deep OS Integrations require specific exceptions.

You are EXPLICITLY AUTHORIZED to add the following dependencies and their associated generators to pubspec.yaml without asking for further permission:
- workmanager (For the Robust Background Scheduler)
- isar, isar_flutter_libs, isar_generator, build_runner (For the Storage Engine Evolution)

Do not add any other state management (like provider/riverpod) or UI libraries. Stick strictly to the approved Phase 4 backend libraries.
