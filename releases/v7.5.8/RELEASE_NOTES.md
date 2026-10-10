## Notekar v7.5.8

Signed release - built automatically from the branch.

### What's New
- Polish settings UI, update center, profile lightbox, and swipe deletion
- 3D Angry Birds avatars, telemetry visualizer, and system refinements
- Polish timeline media filter, 3D avatars, diagnostics animations, and system resilience
- Apple emoji avatars, mid-session goal celebrations, wallet pass, and timeline parity
- Polish timeline rail alignment, search edit affordance, documentation & repo hygiene
- Overhaul rest recovery state machine, multimodal hierarchy, and theme contrast
- Overhaul targets & goals engine, apple hig cards, and multimodal logging
- Add Twitter-style image attachments and direct voice notes
- Refine Apple HIG controls, app icons grid, God Mode flow, and timeline sessions
- Complete Apple HIG settings overhaul and timeline selection polish
- Resolve full audit matrix, harden gitignore, and streamline README
- Route dashboard goals to history, add beta backup warning popup, and clarify background safeguards
- Replicate 0c1851b1 classic single-group settings architecture while preserving modern engine capabilities
- Surgical merge of c05c8b09 Apple HIG sheets with modern engine capabilities
- Intelligence Hub offloading, Icon Standardization, and History Settings Refactor
- Widget IPC Redesign & WorkManager Initialization
- Static App Shortcuts manifest
- Implement native FTS Indexing for UI search
- Isolate offloading for intelligence hub and massive timeline filtering
- Notification consistency channels and remove widget state desync
- Restructure settings into Domain Model and integrate pause system into toolbar

### Improvements
- Apple HIG minimalist splash screen redesign and startup performance overhaul
- Updated \main.dart\ startup routines to initialize the Isar core.
- Storage Engine Evolution to Isar
- Unified Notification Consistency System
- Domain-driven Settings redesign, God Mode Hub, and Material Icon standardization

### Bug Fixes
- Omit ndkVersion pin to prevent runner download crash and untrack gitignored files
- Ensure Isar Linux binary in CI, resilient in
- Resolve untracked gap conflict error and lock interval editing
- Preserve isOngoing state for unclosed sessions across multiple in moments
- Restore isOngoing calculation and resolve mock date test failures
- Overhaul session ending & rest pipeline, polish god mode and settings
- Prevent null check crash when ending live rest session
- Format activity_tag and resolve persistent notification channel in MainActivity
- Resolve untracked gap consumption, lock gap logging to sessions, and fix live session lifecycle
- Improve configured notification modes, atomic rest-gap logging, launcher icon selection, reminder fallbacks, and settings previews
- Implement antigravity repair plan across gap logging, rest authority, calendar parity, life audit, and quick composer
- Hide God Mode until unlocked and ensure robust revocation persistence
- Resolve isar compileSdk and AAPT shortcut string reference errors
- Ensure Isar desktop core initialization and test directory isolation
- Resolve isolate unsendable context exception and optimize timeline rendering

### Integrity

- **Build Tag**: 26BR1011 (version 7.5.8+26101101)
- **Automated Tests**: All unit & widget tests passing (0 failures, 0 lints)
