## Notekar v7.5.2

Signed release — built automatically from the branch.

### What's New

- **Plus Notes & Journaling Canvas**: Dedicated long-form writing canvas with top-left Plus button
  on note sheet and unrestricted character limit.
- **History Note Editing Parity**: Full editing parity for existing timeline notes (`noteMoment`
  resolution) without data loss.
- **Customizable Quick Hashtags**: Long-press any quick tag chip in note dialog to customize
  shortcuts tailored to your workflow.
- **Pure 12-Hour Distraction-Free Clock**: Clean digits on home screen clock face without AM/PM text
  clutter; explicit AM/PM preserved in History and Search.
- **Crisp Single Tactile Touch**: Unified single-burst haptic clicks across all interactive
  elements, eliminating double bursts.

### Improvements

- **Streamlined 5-Page Welcome Onboarding**: Condensed welcome sheet into 5 high-impact pages with
  consolidated Permissions & System Reliability center.
- **Settings Update Center "Rm -rf Cache"**: Renamed installer cache auto-delete switch with full
  search indexing, guides, and help FAQs.

### Bug Fixes

- **Sobriety & Life Audit Launcher Widgets**: Resolved RemoteViews layout crash (`<View>` to
  `<FrameLayout>`), fixed initial placement compact sizing, added graceful zero/disabled state
  prompts, and enabled direct settings deep-linking.

### Integrity

- **Build Tag**: 26BR0916 (version 7.5.2+26091601)
- **Automated Tests**: All 160 unit & widget tests passing (0 failures, 0 lints)
- **Architecture**: 100% offline-first, zero telemetry, local sandboxed storage
