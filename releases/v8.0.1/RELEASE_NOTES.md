## Notekar v8.0.1

Signed release - built automatically from the branch.

### What's New
- **Routine / Habits Quick Filter**: 1-tap Routine filter pill directly on the primary horizontal filter bar in History, allowing instantaneous isolation of all habit checkpoints with full localization.
- **Natural Forward-Time Scheduling**: Habit duration adjustments naturally anchor start time and advance end time forward (`_startPoint.add(duration)`). Dynamic boundary guards eliminate Cupertino date picker assertion crashes.
- **Custom Habit Duration with iOS Picker**: Dedicated `+` custom duration pill opening an authentic Apple HIG bottom sheet with `CupertinoTimerPicker` for custom hours and minutes.
- **Quick 5m & 10m Micro-Durations**: Added `5m` and `10m` quick chips right at the start of the habit duration row (`[5, 10, 15, 30, 45, 60, 90, 120]`) for frictionless micro-habit logging.
- **Apple HIG Accessible Single Timestamp Button**: Elevated "Log as single timestamp" into a prominent, high-contrast `OutlinedButton.icon` with 48dp accessibility touch target.
- **High-Density Asset Optimization (~4.8MB Saved)**: Optimized 8 uncompressed preset avatar JPEGs and the Diwali notice banner, cutting ~4.8MB directly from the APK bundle (-92.7% reduction) with zero decoding lag.
- **Resilient Multi-Hop In-App Updater**: Enhanced in-app update engine supporting 10-hop GitHub AWS S3 redirects, paired with multi-manifest checksum verification and ZIP binary fallback validation.
- **Dual-Key Theme & Accent Persistence**: Dual-key persistence across updates (`m-theme`/`theme`, `m-accent-color`/`accent_color`) with synchronous live propagation across all open sheets and screens without restart.
- **Light Theme High-Contrast Specular Borders**: Apple HIG `#D1D1D6` border tokens, deep graphite `#1C1C1E` icons/text contrast, and synchronized status bar icon brightness so controls and notifications never wash out.

### Integrity

- **Build Tag**: 26BR1120 (version 8.0.1+26112001)
- **Automated Tests**: All 605 unit & widget tests passing (0 failures, 0 lints)
