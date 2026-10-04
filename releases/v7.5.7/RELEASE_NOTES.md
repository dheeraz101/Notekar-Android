## Notekar v7.5.7

Signed release - built automatically from the branch.

### What's New
- **Concurrency Engine (Isolate Offloading)**: Heavy analytical computations across Life Audit (`LifeAuditService.calculateAsync`) and Executive Dashboard metrics (`DashboardMetricsService.calculateAsync`) are now offloaded to Dart 3 background threads via `Isolate.run`, ensuring locked 120fps UI scrolling even with tens of thousands of historical logs.
- **High-Performance Search Indexing**: Replaced O(N) linear scans with a dedicated in-memory inverted token index (`SearchIndexService`), prefix trie for hashtag autocomplete, and fast candidate relevance ranking.
- **Storage Engine Evolution & Secondary Indexing**: `MomentRepository` upgraded with in-memory secondary indices (`_momentIdIndex`) for O(1) instantaneous ID lookups and binary range slicing (`getMomentsBetween`) for O(log N) date range filtering.
- **Circuit Breaker Fault Isolation**: Automated 3-strike failure isolation mechanism (`CircuitBreakerService`) protecting Digital Wellbeing, analytics, and platform channels from cascading exceptions, with manual trip/reset in God Mode and status indicators in Diagnostics.
- **Guaranteed OS Daily Maintenance Scheduler**: Native Android `AlarmManager` midnight maintenance trigger (`ACTION_DAILY_MAINTENANCE`) in `ReminderReceiver.kt` for automatic daily rolling snapshots, 30-day trash auto-purging, and database storage compaction.
- **Life Audit in History Actions**: Direct router access to Life Audit & Horizon ledger directly from the History action sheet, paired with `PageStorageKey` scroll preservation.

### Improvements
- **Native State Controller Decoupling**: Migrated global state into `SettingsController` with `InheritedNotifier` for surgical, single-source-of-truth re-renders.
- **Apple HIG Design Polish**: Unified 28pt continuous squircle radii across all surface cards, sheets, and dialogs. Expanded history cards and standardized iconography.
- **Settings Search Indexing**: Complete indexed routing for Fault Isolation, Floating Timer Pill, and Acoustic Feedback.

### Bug Fixes
- Resolved overlay toggle persistence across app restarts.
- Resolved foreground-to-background pause state desynchronization.
- Fixed scroll-position resets on history sheet re-entry.
- Cleaned up lingering edge-case layout overflows.

### Integrity
- **Build Tag**: 26BR1004 (version 7.5.7+26100401)
- **Automated Tests**: All 243 unit & widget tests passing (0 failures, 0 lints)
