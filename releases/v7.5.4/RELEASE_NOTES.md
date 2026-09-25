# NoteKar v7.5.4

> *Personal Identity, Life Horizons & Mindful Continuity*

Signed release — built automatically from the branch.

### What's New

- **Personal Profile & Identity System**:
  - Integrated custom avatar personalization and user alias synchronized across Settings and home views.
  - Added **Memento Mori Life Horizon Card**: visual lifespan progression, seasons remaining, and target horizon calculations.
  - Dedicated Cupertino bottom sheet for Date of Birth selection following modular OS-level picker standards.
  - Elegant **Shareable Life Horizon Card** for exporting life milestone cards with privacy-preserving local rendering.
- **Adaptive Startup Mode & "Last Used" Memory**:
  - New **Last Used** option in Capture Settings automatically restores your active logging mode on cold start.
  - Full Settings Search indexing (keywords: `last used`, `remember`, `resume`) and comprehensive Help & Guides entries.
- **Habit Decay & Streak Guardian Rest Neutrality**:
  - Exponential habit strength decay calculation ($H(t) = H_0 \cdot 2^{-t / 12}$), modeling natural behavioral habits.
  - Vacation and rest day neutrality in Streak Guardian, preventing punitive streak breaks during intentional rest.
- **Universal Migration Importer**:
  - Standalone **Migrate from Other Apps** card in Backup & Export.
  - Zero-cloud offline migration engine supporting Loop Habit Tracker (CSV) and HabitKit (JSON) imports.
- **Hardware & Performance Diagnostics**:
  - Real-time device health telemetry: memory consumption, display refresh rates (60Hz / 120Hz), and thermal status.

### Improvements & Refinements

- **Modal Optics & Responsive Controls**:
  - Eliminated nested double corner radius visual artifacts on bottom sheets and note sheets.
  - Replaced 24-hour time format switch with a responsive 2-card Cupertino visual segment selector.
  - Enhanced theme card border contrast across Light, Dark, and AMOLED modes with visible hairline strokes.
- **Typography & Precision**:
  - Perfect circular avatar clipping without corner bleeding.
  - Concise metrics copy across social share cards preventing text ellipsis clipping.
  - Instant FAQ answer resolution in Search Notes & Settings Search.

### Bug Fixes

- Fixed instant avatar preview reactivity across settings and setup sheets.
- Added boundary assertion guards for Memento Mori horizon age adjustments.
- Resolved edge-case storage crashes and IPC state synchronization during rapid two-way toggle switches.
- Verified backup import validator compatibility with `'last-used'` startup configurations.

---

### Integrity

- **Build Tag**: `26BR0925` (version `7.5.4+26092501`)
- **Automated Tests**: All 215 unit & widget tests passing (0 failures, 0 lints)
- **Privacy Standard**: 100% offline, zero trackers, sandboxed local storage
