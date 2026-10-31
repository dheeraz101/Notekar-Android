## Notekar v7.5.12

Signed release — built with Apple HIG visual surgery, Android 15 compliance, and sovereign privacy standards.

### What's New
- **Quick Settings Notification Tile (`FloatingBubbleTileService`)**: Toggle the floating timer bubble on or off directly from Android's system status bar Quick Settings shade without opening the app.
- **Interactive Floating Bubble Dismissal (`FloatingTimerService`)**: Drag the floating bubble to the animated bottom screen '✕' drop-target to dismiss it instantly. Re-summon at any time via the Quick Settings Tile or home screen widget.
- **Custom Canvas Habit Creation (`AddEditHabitSheet`)**: Dedicated interactive bottom sheet to author custom habits directly on the canvas with emoji selector, custom interval cadences, and deletion confirmation safeguards.
- **Media Symmetry in Note Previews (`NotePreviewSheet`)**: Play back voice notes directly with the inline `TimelineVoicePlayerPill` and preview photo moments with `TimelineMediaAttachmentCard` without leaving the note preview modal.
- **Sovereign App Permissions Dashboard (`AppPermissionsSettingsPage`)**: Comprehensive live inspection of all 7 device capabilities (Microphone, Camera, Notifications, Overlay, Exact Alarms, Battery Exemption, and Usage Access) with Apple HIG decoupled typography and interactive `Enable ›` / `✓ Granted` action pills.
- **Global Content Rating Scorecard (`ContentRatingSettingsPage`)**: Certified IARC Everyone, ESRB Everyone, PEGI 3, and USK 0 compliance disclosures with a 0/5 mature topics scorecard using Apple soft-tinted squircle glyph badges (`softIcon: true`).
- **Data Safety Nutrition Card (`DataSafetySettingsPage`)**: Redesigned Google Play Store Disclosures card featuring 24pt continuous squircle curvature, whisper-thin borders, 20x20 circular checkmark badges, and 100% on-device local Isar encryption.

### Improvements & Polish
- **App Icons Preview Card**: Upgraded top instruction container to continuous 24pt squircles with responsive adaptive `Wrap` headers withstanding up to 200% system accessibility font scaling.
- **Touch Targets & Edge Insets**: Reinforced Checkpoints bar touch targets to the Apple HIG 44pt minimum and aligned all settings groups to a unified 16pt margin.
- **Pre-Commit Hook & Formatting**: 100% of Dart codebase formatted with `dart format`, maintaining zero analyzer issues across 422 passing automated tests.

### Integrity
- **Build Tag**: 26BR1101 (version 7.5.12+26110101)
- **Automated Tests**: 422 unit & widget tests passing (0 failures, 0 lints)
- **Privacy Architecture**: 100% offline, zero telemetry, local Isar encrypted
