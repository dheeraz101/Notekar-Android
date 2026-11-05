# NoteKar 500+ Micro-Improvements Inventory: Part 1
## Focus Area: Home Screen, Clock Face, Session Lifecycle, Gestures & Tactile Micro-Interactions
### Items: IMP-001 to IMP-100

---

### IMP-001: 12-Hour Clock Mode Missing AM/PM Period Indicator
- **Category:** Visual Polish / Functional
- **Current behaviour:** When `use24HourFormat` is set to `false`, `ClockFace` in `lib/widgets/clock_face.dart:176-180` calculates the 12-hour hour (`widget.now.hour % 12 == 0 ? 12 : widget.now.hour % 12`) but explicitly sets `period = '';`. Consequently, users in 12-hour mode see numbers like `9:41` with no indication whether it is AM or PM.
- **Proposed improvement:** Set `period = widget.now.hour >= 12 ? ' PM' : ' AM';` and render it using the pre-configured `periodFontSize` and `periodFontWeight` tokens with optical baseline alignment.
- **User benefit:** Eliminates ambiguity for users preferring 12-hour display, especially in dark environments or shift work.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/clock_face.dart:179`
- **Verification:** Toggle `use24HourFormat` to false in Display settings; verify that ' AM' or ' PM' displays seamlessly beside seconds on the home clock face.

---

### IMP-002: Dynamic Contrast Correction for `NkButton.primary` Text on Light Accents
- **Category:** Accessibility / Visual Polish
- **Current behaviour:** `NkButton` in `lib/widgets/design_system/nk_button.dart:94` hardcodes `foregroundColor = Colors.white;` for `NkButtonVariant.primary`. When a user selects a high-luminance accent color (e.g., Gold `#FFD700`, Lime `#32D74B`, or Cyber Yellow), the contrast ratio drops below 2.1:1, violating WCAG AA/AAA standards.
- **Proposed improvement:** Replace `Colors.white` with `p.onAccent`, which dynamically calculates relative luminance (`accent.computeLuminance() > 0.45 ? Colors.black : Colors.white`).
- **User benefit:** Primary buttons remain razor-sharp and effortlessly readable regardless of the user's custom accent color.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/widgets/design_system/nk_button.dart:94`
- **Verification:** Change accent color to 'Gold' in Personalization; verify all primary buttons render black text with crisp contrast.

---

### IMP-003: Empty Description Ghost Spacer Elimination in `NkEmptyState`
- **Category:** Layout / Accessibility
- **Current behaviour:** In `lib/widgets/design_system/nk_empty_state.dart:63-74`, when `description` is an empty string, the widget still inserts `const SizedBox(height: 8.0)` and an empty `Text('', ...)`. This introduces an unwanted 8px vertical gap and produces an empty accessible node for screen readers.
- **Proposed improvement:** Wrap the spacing and text in `if (description.trim().isNotEmpty) ...[ const SizedBox(height: 8.0), Text(description, ...) ]`.
- **User benefit:** Compact empty states render with true vertical centering and screen readers don't stutter on blank text elements.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P2
- **Implementation location:** `lib/widgets/design_system/nk_empty_state.dart:63`
- **Verification:** Pass empty description to `NkEmptyState`; verify no extraneous SizedBox or TalkBack focus node is generated.

---

### IMP-004: Accelerometer Parallax Throttle to 60fps Frame Budget
- **Category:** Performance / Battery Optimization
- **Current behaviour:** In `lib/screens/note_kar_home.dart:295-300`, accelerometer sensor updates update `_motion.value` on every hardware event callback, which can fire at up to 200Hz on modern 120Hz/144Hz displays, causing excessive micro-allocations and GC pressure during idle battery states.
- **Proposed improvement:** Add a 16ms temporal throttle (`if (now - _lastMotionMs < 16) return;`) before updating `_motion.value`.
- **User benefit:** Prevents battery drain and sensor jitter during home screen resting states.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:298`
- **Verification:** Monitor Android CPU profiler with home screen sitting idle; observe a 40% reduction in background frame scheduling.

---

### IMP-005: Dual Semantics Announcement Suppression on `NkSwitchTile`
- **Category:** Accessibility / TalkBack
- **Current behaviour:** `NkSwitchTile` in `lib/widgets/design_system/nk_list_tile.dart:209-289` wraps an `InkWell` inside a `Semantics(toggled: value)` widget, while simultaneously embedding a `Switch.adaptive` child that has its own native semantic toggle node. TalkBack reads "Double tap to toggle" twice.
- **Proposed improvement:** Wrap the trailing `Switch.adaptive` in `ExcludeSemantics(child: Switch.adaptive(...))` so the outer tile retains single, unified accessibility control.
- **User benefit:** Clean, pleasant, and professional TalkBack experience for visually impaired users.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/design_system/nk_list_tile.dart:282`
- **Verification:** Enable TalkBack; focus on any switch tile in Settings; verify single clean announcement ("App Lock, On, Double tap to toggle").

---

### IMP-006: Continuous Superellipse Transition on Clock Pulse Scale Animation
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** In `lib/widgets/clock_face.dart:242-245`, the clock pulse uses `Curves.easeOutCubic` with a linear scale factor `0.96`. While smooth, the transition feels mechanical rather than organic.
- **Proposed improvement:** Use `NkTokens.curves.appleEase` (`Cubic(0.2, 0.9, 0.3, 1.0)`) with a quick 120ms spring rebound (`duration: const Duration(milliseconds: 180)`).
- **User benefit:** Tapping IN/OUT feels physical and elastic, resembling Apple Watch complications.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/clock_face.dart:244`
- **Verification:** Tap IN to start a session; observe the snappy, organic rebound contraction of the digital clock numbers.

---

### IMP-007: Tabular Monospace Figure Guarantee on Seconds Display
- **Category:** Visual Polish / Typography
- **Current behaviour:** In `lib/widgets/clock_face.dart:216-218`, the seconds text style applies font sizes and weights but omits `fontFeatures: const [FontFeature.tabularFigures()]` when custom font fallbacks like Roboto or Arial Narrow take effect. This causes numbers like '11' to take less horizontal space than '88', producing horizontal digit jitter every second.
- **Proposed improvement:** Explicitly declare `fontFeatures: const [FontFeature.tabularFigures()]` across both `hm` and `sec` TextSpans.
- **User benefit:** Eliminates horizontal dancing/jitter of clock seconds, creating a rock-solid, calm visual experience.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/clock_face.dart:216`
- **Verification:** Watch the clock seconds tick from '09' to '11'; confirm absolute zero horizontal displacement of adjacent glyphs.

---

### IMP-008: Home Minimal Toolbar Pill Haptic Detent on Category Swipe
- **Category:** User Flows / Tactile Feedback
- **Current behaviour:** Swiping horizontally across the clock face in `lib/screens/note_kar_home.dart:257-293` switches categories (`_onNextGoal()` / `_onPrevGoal()`) and calls `_showToast` with `withHaptic: false`. The user receives no tactile indication that the threshold was crossed.
- **Proposed improvement:** Trigger `HapticFeedback.selectionClick()` right as the swipe threshold delta (40dp) is passed before updating the category.
- **User benefit:** Immediate physical tactile confirmation that a category or goal cycle occurred under the thumb.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:268,287`
- **Verification:** Swipe across the clock face; feel the crisp rotary click in the hand exactly as the category title updates.

---

### IMP-009: Home Screen Double-Tap Session Discard Shield
- **Category:** Reliability / Data Safety
- **Current behaviour:** If a user accidentally double-taps the OUT button or end session button, two discrete lifecycle events are dispatched, potentially corrupting interval duration calculations or generating a zero-second phantom moment.
- **Proposed improvement:** Add a 500ms debounce guard (`if (DateTime.now().millisecondsSinceEpoch - _lastActionTime < 500) return;`) on all primary session control handlers.
- **User benefit:** Prevents phantom logs and accidental double-submission when hands are wet or gloves are worn.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1840`
- **Verification:** Rapidly tap the OUT button 5 times; verify exactly one clean session end event is processed and logged.

---

### IMP-010: Dynamic Header Capsule Velocity Decay on Dismissal
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** Collapsing `DynamicHeaderCapsule` (`lib/widgets/dynamic_header_capsule.dart:88-100`) uses a hardcoded animation duration regardless of drag fling velocity, making quick upward swipes feel sluggish.
- **Proposed improvement:** Integrate `GestureDetector.onVerticalDragEnd` to calculate dismiss fling velocity and set dynamic animation duration down to 140ms on high-velocity flings.
- **User benefit:** Fluid and responsive interaction that respects user intent and gesture speed.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:95`
- **Verification:** Fling upward on the expanded dynamic header capsule; verify snappy, instantaneous snap-back into the compact pill.

---

### IMP-011: Live Session Pause Timer State Preservation Across Android Process Death
- **Category:** Reliability / Architecture
- **Current behaviour:** When a session is paused (`_isPaused = true`, `_pausedAt = ms`), `_pausedAt` is kept in in-memory state. If the OS terminates the background app due to low RAM while paused, on cold restore the session calculation defaults to the original start time minus the paused duration, losing exact pause boundary data.
- **Proposed improvement:** Persist `notekar.session_paused_at` and `notekar.session_is_paused` to `SharedPreferences` on state change; restore them in `_loadInitialState`.
- **User benefit:** Paused workouts, deep work blocks, or meditation sessions never lose their paused state or timing fidelity during background restarts.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/screens/note_kar_home.dart:132-133`
- **Verification:** Start a session, pause it, kill process via ADB (`adb shell am kill app.notekar.notekar`), reopen app; verify session remains paused at the exact elapsed duration.

---

### IMP-012: In-App PIN Setup Overlay Keyboard Auto-Focus Timing
- **Category:** User Flows / UX
- **Current behaviour:** When opening the PIN setup overlay (`HomePinSetupOverlay` in `lib/widgets/home_pin_setup_overlay.dart`), the numeric keypad sometimes fails to raise automatically on Samsung OneUI and Xiaomi MIUI devices due to focus arena race conditions.
- **Proposed improvement:** Delay the focus request by one frame using `WidgetsBinding.instance.addPostFrameCallback((_) => _pinFocusNode.requestFocus())`.
- **User benefit:** Numeric keypad opens instantly without requiring an extra tap on the PIN input boxes.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_pin_setup_overlay.dart:58`
- **Verification:** Open PIN setup on a real Android device; verify the keypad appears synchronously with the bottom sheet slide-in.

---

### IMP-013: Sobriety Streak Card Micro-Pulse Milestone Glow
- **Category:** Perceived Quality / Delight
- **Current behaviour:** When a sobriety streak reaches a milestone (e.g. 7 days, 30 days, 100 days), `HomeSobrietyStreakCard` (`lib/widgets/home_sobriety_streak_card.dart:80-120`) displays a static trophy icon with no special animation.
- **Proposed improvement:** Add a subtle, ambient breathing gradient glow (`NkTokens.durations.smooth`) behind the milestone badge using the theme's gold/amber accent.
- **User benefit:** Gives users a subconscious dopamine boost and sense of meaningful achievement for maintaining consistency.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_sobriety_streak_card.dart:95`
- **Verification:** Set mock streak to 30 days; verify gentle breathing glow surrounds the trophy chip.

---

### IMP-014: Checkpoints Quick Bar Scroll Persistence Across Tab Switches
- **Category:** User Flows / UX
- **Current behaviour:** Swiping the horizontal `CheckpointsQuickBar` (`lib/widgets/checkpoints_quick_bar.dart:45-90`) scrolls to habit #6. When opening Settings or History and returning, the horizontal scroll position resets to 0.
- **Proposed improvement:** Attach a `PageStorageKey('checkpoints_quick_bar_scroll')` to the `ListView.builder`.
- **User benefit:** Users tracking afternoon or evening habits don't have to scroll repeatedly every time they return to the home screen.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart:52`
- **Verification:** Scroll quick bar to end, open settings, navigate back; verify horizontal position remains precisely anchored.

---

### IMP-015: Dynamic Header Capsule Circadian Sun/Moon Optical Indicator
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** The Dynamic Header Capsule displays an intentional percentage or category title, but provides no visual cue reflecting morning, afternoon, twilight, or night.
- **Proposed improvement:** Render a miniature 12dp astronomical glyph (Sunrise `06:00-11:59`, Sun `12:00-17:59`, Sunset `18:00-20:59`, Crescent Moon `21:00-05:59`) with a soft atmospheric tint.
- **User benefit:** Strengthens the app's life ledger identity and creates a calming, circadian temporal awareness.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:180`
- **Verification:** Change system clock to 22:00; verify smooth crescent moon icon appears inside the resting pill.

---

### IMP-016: Zero-Flicker Clock Face Rendering on Second Rollover
- **Category:** Performance / Visual Polish
- **Current behaviour:** In `lib/widgets/clock_face.dart:50-59`, `_scheduleNextTick()` uses a 1-second `Timer` calculated from `1000 - now.millisecond`. Under heavy OS load, the timer may fire at 998ms, triggering two quick successive rebuilds for the same second.
- **Proposed improvement:** Ensure `_now = DateTime.now()` compares `_now.second != previousSecond` before dispatching `setState()`.
- **User benefit:** Eliminates microscopic frame skips and CPU stutter during high-framerate second transitions.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P1
- **Implementation location:** `lib/widgets/clock_face.dart:56`
- **Verification:** Log frame timings over 60 seconds; confirm exactly 60 distinct repaints occur without micro-burst duplicates.

---

### IMP-017: Activity Ring Painter Arc Smoothing Anti-Aliasing
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/home_activity_ring_painter.dart:30-45`, stroke cap is set to `StrokeCap.round`, but the paint configuration lacks `Paint()..isAntiAlias = true` and `filterQuality = FilterQuality.high`. On low-DPI Android devices (mdpi/hdpi), the ring tips show noticeable staircase rasterization.
- **Proposed improvement:** Explicitly enable `isAntiAlias = true` on both background track paint and foreground arc paint.
- **User benefit:** Smooth, perfectly rounded ring arcs on all Android hardware tiers.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P3
- **Implementation location:** `lib/widgets/home_activity_ring_painter.dart:32`
- **Verification:** Inspect activity ring arcs on a 720p Android device; verify crisp vector-like curves with zero pixel staircasing.

---

### IMP-018: Voice Quick-Recording Cancel Swipe Gesture in Minimal Toolbar
- **Category:** User Flows / UX
- **Current behaviour:** When recording a voice note from the home toolbar, the user must tap the cancel button. There is no horizontal slide-to-cancel gesture like in WhatsApp or Telegram.
- **Proposed improvement:** Add a horizontal drag gesture recognizer on the recording pill that triggers cancel when dragged left by >60dp, accompanied by `HapticFeedback.mediumImpact()`.
- **User benefit:** Fast, muscle-memory cancellation of unintended voice recordings without requiring pinpoint accuracy.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/toolbar.dart:310-340`
- **Verification:** Start voice recording, slide thumb left; verify recording discards and audio file is unlinked.

---

### IMP-019: Home Momentum Card Tap-to-Cycle Metric View
- **Category:** Functional Intelligence / UX
- **Current behaviour:** `HomeMomentumCard` in `lib/widgets/home_momentum_card.dart` displays today's tracked hours. Tapping the card does nothing.
- **Proposed improvement:** Allow tapping the card to cycle through 3 metrics: (1) Total Tracked Duration, (2) Deep Focus Intentional Ratio %, (3) Remaining Daily Horizon. Save the selected index to user preferences.
- **User benefit:** Instant executive glanceability without needing to open the full Intelligence Hub screen.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_momentum_card.dart:65`
- **Verification:** Tap momentum card on home screen; verify numbers cycle smoothly between Hours -> Focus % -> Remaining Horizon with tactile feedback.

---

### IMP-020: Extended Session Duration Overflow Wrap Defense
- **Category:** Visual Polish / Edge Cases
- **Current behaviour:** When a session exceeds 24 hours (e.g. multi-day travel or continuous tracking), the clock face duration string `HH:MM.SS` (`lib/widgets/clock_face.dart:163`) can overflow the bounds of narrow 320dp phone screens, causing `FittedBox` downscaling that shrinks the primary digits down to unreadable sizes.
- **Proposed improvement:** When `elapsed.inHours >= 24`, format as `1d 04h:12m` and move the milliseconds/seconds sub-counter below or into a compact badge.
- **User benefit:** Large display numerals remain hero-sized and readable even during ultra-long multi-day sessions.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/clock_face.dart:160`
- **Verification:** Simulate session starting 36 hours ago; observe clear `1d 12h:00m` layout without micro-text shrinkage.

---

### IMP-021: Home Screen App Bar Title Long-Press Quick Diagnostic Action
- **Category:** Functional / Debuggability
- **Current behaviour:** Long-pressing the app logo or header title on the home screen does nothing.
- **Proposed improvement:** Long-pressing the brand header triggers a light haptic tick and displays a non-intrusive bottom sheet showing database record count, database integrity hash, and active storage paths.
- **User benefit:** Instant power-user diagnostic inspection without navigating 4 levels deep into Settings -> Diagnostics.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/screens/note_kar_home.dart:820`
- **Verification:** Long-press NoteKar title; verify sovereign diagnostic HUD pops up with active Isar entry counts and engine state.

---

### IMP-022: Dynamic Header Category Pill Reordering Persistence
- **Category:** Personalization / UX
- **Current behaviour:** In `DynamicHeaderCapsule` (`lib/widgets/dynamic_header_capsule.dart:31-35`), categories appear in insertion order. Users cannot re-order them to put their most frequent category first without deleting and recreating categories.
- **Proposed improvement:** Add long-press drag-to-reorder mode to the category strip in the expanded header sheet, saving the new order to `CategoryService`.
- **User benefit:** One-handed ergonomics: users can place their 2 most critical categories directly under their thumb.
- **Implementation effort:** 3
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_category_pills.dart:110`
- **Verification:** Drag 'Deep Focus' before 'Work'; reopen app; confirm new order is preserved across launches.

---

### IMP-023: Accidental OUT Confirmation Shield When Duration < 15 Seconds
- **Category:** Reliability / Data Safety
- **Current behaviour:** If a user accidentally taps OUT within 10 seconds of tapping IN, a 10-second moment is saved to the database, cluttering history with micro-blips.
- **Proposed improvement:** If a session is ended within 15 seconds, show an instant undo snackbar: `"Session was under 15s. [Discard] [Keep]"`.
- **User benefit:** Prevents accidental pocket-tap sessions from polluting weekly analytics and streak charts.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1860`
- **Verification:** Start session, immediately tap OUT after 3 seconds; verify undo snackbar offers instant 1-tap discard.

---

### IMP-024: PressableScale Micro-Bounce Physics Tuning
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** `PressableScale` in `lib/widgets/pressable_scale.dart:25-35` uses a fixed `0.97` downscale with `Curves.easeInOut`. It lacks a subtle tactile spring overshoot upon release.
- **Proposed improvement:** Enhance the scale transition on pointer-up using `Curves.easeOutBack` with a 1.01 overshoot rebound before settling at 1.00.
- **User benefit:** Buttons feel bouncy, physical, and deeply satisfying to press, matching iOS system button physics.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/pressable_scale.dart:28`
- **Verification:** Tap any `NkButton` or card; observe the tactile spring rebound on pointer release.

---

### IMP-025: Acoustic Feedback Sound Pool Hardware Pre-Warming
- **Category:** Performance / Audio
- **Current behaviour:** In `MainActivity.kt:45-48`, the `SoundPool` loads mechanical click sounds on demand during the first user tap, causing a noticeable 80-120ms audio latency on the first button press.
- **Proposed improvement:** Pre-load and warm `clickSoundId` and `shhhSoundId` during `configureFlutterEngine` background thread initialization.
- **User benefit:** Zero-latency audio feedback: the acoustic click plays exactly synchronized with the physical touch.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:98`
- **Verification:** Cold-start the app; tap IN; verify the mechanical tick audio plays synchronously with zero audible delay.

---

### IMP-026: Zen Day Gauge Smooth Angle Interpolation
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** In `lib/widgets/zen_day_gauge.dart:40-75`, the day gauge needle jumps abruptly when the device clock ticks or when opening the screen.
- **Proposed improvement:** Animate the needle sweep on entry using `Tween<double>(begin: 0.0, end: targetFraction)` over 600ms with `Curves.easeOutCubic`.
- **User benefit:** Elegant, tranquil needle sweep whenever opening the dynamic header or day gauge.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/zen_day_gauge.dart:55`
- **Verification:** Open Zen Day Gauge; observe the needle glide smoothly into position from 0 to current diurnal time.

---

### IMP-027: Battery Saver Mode Automatic Parallax Deactivation
- **Category:** Performance / Battery Optimization
- **Current behaviour:** Sensor parallax tracking continues listening to `sensors_plus` even when the Android device enters Battery Saver mode.
- **Proposed improvement:** Listen to Android PowerManager `isPowerSaveMode` state; dynamically pause `_motionSub` when battery saver is active.
- **User benefit:** Maximizes battery longevity when the user is below 20% battery.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:295`
- **Verification:** Enable Battery Saver in Android system settings; verify accelerometer listening halts immediately.

---

### IMP-028: Home Clock Font Switching Hero Preview
- **Category:** Personalization / Visual Polish
- **Current behaviour:** In `lib/dialogs/settings/display_settings_page.dart:210-245`, switching the clock font changes the dropdown, but users cannot see how the actual home hero digits look until leaving settings.
- **Proposed improvement:** Render a live 48dp sample of the home clock digits directly inside each font selection card in Display settings.
- **User benefit:** Effortless visual choice without needing to navigate back and forth to preview typography.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/display_settings_page.dart:225`
- **Verification:** Open Display Settings -> Clock Font; see live scaled renderings of 'BebasNeue', 'Inter', and 'SF Pro Display'.

---

### IMP-029: Top Fade Blur Edge Hairline Blend
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/top_fade_blur.dart:18-35`, the blur gradient uses a sharp top container edge that can create a faint 1px line artifact against pure AMOLED `#000000` backdrops on OLED panels.
- **Proposed improvement:** Ensure the top stop of the gradient is `Colors.transparent` with a smooth quad easing curve to zero opacity.
- **User benefit:** Seamless, invisible blending of scrolling content under the status bar with zero visual seams.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/top_fade_blur.dart:24`
- **Verification:** In AMOLED theme, scroll notes under the top bar; verify perfectly dissolved gradient with zero raster lines.

---

### IMP-030: Android Predictive Back Gesture Live Screen Peeking
- **Category:** Android System Integration / UX
- **Current behaviour:** On Android 14+ devices, pressing back from a full sheet performs a standard exit animation without supporting Android's predictive back gesture peek.
- **Proposed improvement:** Leverage Flutter 3.22+ `PredictiveBackPageTransitionsBuilder` or `PopScope(canPop: true, onPopInvokedWithResult: ...)` to provide smooth scale-down peeking.
- **User benefit:** Modern, fluid Android 14/15 native gesture navigation feel.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/predictive_back_peek.dart:30`
- **Verification:** On Android 14+, swipe slowly from left edge; observe sheet smoothly scaling down to preview the home screen behind.

---

### IMP-031: Home Swipeable Mode Toast Haptic Feedback Option
- **Category:** Tactile Feedback / UX
- **Current behaviour:** `_onNextGoal()` in `lib/screens/note_kar_home.dart:268` hardcodes `withHaptic: false` for the toast popup.
- **Proposed improvement:** Respect the global `_haptics` preference and fire a light selection haptic tick if haptics are enabled.
- **User benefit:** Multisensory feedback confirming category changes without needing to look down at the toast message.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/screens/note_kar_home.dart:268`
- **Verification:** Swipe between modes; verify toast and haptic click fire in harmony.

---

### IMP-032: Single Mode Sequential Number Counter Reset at Midnight Option
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/screens/note_kar_home.dart:168`, `_resetSingleDaily` exists as a flag but relies on manual trigger check rather than an automated midnight boundary event.
- **Proposed improvement:** In `callbackDispatcher` (`midnight-job`), automatically reset the single moment counter to #1 when `_resetSingleDaily` is enabled.
- **User benefit:** Daily habits and repetitive single logs start fresh at #1 every morning automatically.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/main.dart:88`
- **Verification:** Set mock time past midnight; verify single counter displays #1 on next morning moment log.

---

### IMP-033: Home Toolbar Minimal Capsule Translucency Blur Filter Tuning
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/home_minimal_toolbar_capsule.dart:22-45`, `BackdropFilter` sigma is hardcoded to 10.0, which on low-power GPU chipsets can cause 1-2 dropped frames during rapid list scrolling.
- **Proposed improvement:** Dynamically adjust sigma to 6.0 when `lowPowerMode` or low-end device profile is detected in `AdaptiveEngine`.
- **User benefit:** Maintains 60fps/120fps buttery smooth scroll performance across budget Android devices.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_minimal_toolbar_capsule.dart:30`
- **Verification:** Run flutter frame performance profiling on a low-end test device; verify zero frame spikes during scroll.

---

### IMP-034: Coachmark Tooltip Intelligent Dismissal on Any Tap
- **Category:** User Flows / UX
- **Current behaviour:** `HomeCoachmarkTooltip` (`lib/widgets/home_coachmark_tooltip.dart:35-65`) requires tapping the tiny "Got it" button to dismiss. Tapping outside does not dismiss it.
- **Proposed improvement:** Allow tapping anywhere on the backdrop or tooltip container to dismiss, automatically persisting the dismissal key.
- **User benefit:** Frictionless onboarding: users can tap naturally to proceed without feeling blocked.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_coachmark_tooltip.dart:45`
- **Verification:** Trigger coachmark; tap anywhere on the screen; verify tooltip dismisses smoothly with no lingering obstruction.

---

### IMP-035: Two-Way Mode IN Session Long-Press to Edit Start Time
- **Category:** User Flows / Convenience
- **Current behaviour:** Once an IN session has started, if the user forgot to tap IN 20 minutes ago, they cannot retroactively adjust the session start time without cancelling and manually logging.
- **Proposed improvement:** Long-pressing the active live clock during an ongoing session opens a quick time-picker sheet: `"Adjust Session Start Time"`.
- **User benefit:** Eliminates immense frustration when users start working but forget to tap IN immediately.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1830`
- **Verification:** Start a session; long-press the clock; adjust start time back 15 minutes; observe elapsed duration reflects the correct 15 minutes.

---

### IMP-036: Active Session In-Progress Persistent Android Notification
- **Category:** Android System Integration / Convenience
- **Current behaviour:** When a session is running and the user leaves NoteKar, there is no ongoing status bar chronometer notification unless the user explicitly enabled the floating bubble.
- **Proposed improvement:** Show an ongoing, low-priority silent notification with chronometer (`setShowWhen(true)`, `setUsesChronometer(true)`) and quick "End Session" action.
- **User benefit:** Users can glance at elapsed time from the lock screen or shade and end the session in 1 tap without opening the app.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:650`
- **Verification:** Start session, minimize app; pull down notification shade; observe live chronometer ticking with an 'End Session' action button.

---

### IMP-037: Home Screen Quick Category Creation Inline Sheet
- **Category:** User Flows / UX
- **Current behaviour:** Tapping "+" in the category pills opens the category settings sub-page, navigating away from the home screen.
- **Proposed improvement:** Open a compact bottom sheet (`AppSheet`) directly over the home screen with an input field, color swatch picker, and "Create Category" button.
- **User benefit:** Zero context disruption: create a new category in 3 seconds and immediately log a moment into it.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:2450`
- **Verification:** Tap "+" in category pill bar; verify inline modal sheet opens without leaving the home screen.

---

### IMP-038: Dynamic Header Capsule Drag Handle Visual Affordance
- **Category:** Visual Polish / Discoverability
- **Current behaviour:** In `lib/widgets/dynamic_header_capsule.dart:210-230`, the expanded card lacks a top pill grabber/handle. First-time users do not realize it can be dragged down or swiped up.
- **Proposed improvement:** Add a 36x4dp rounded squircle handle (`p.text3.withValues(alpha: 0.3)`) at the top of the expanded card.
- **User benefit:** Clear, intuitive affordance communicating that the card is draggable.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:215`
- **Verification:** Expand header capsule; observe standard Apple-style grabber bar at top center.

---

### IMP-039: Auto-Scroll to Active Category in Horizontal Pill Strip
- **Category:** User Flows / Ergonomics
- **Current behaviour:** When selecting a category by swiping the clock, the horizontal pill bar in `HomeCategoryPills` does not auto-scroll to bring the newly active category chip into viewport.
- **Proposed improvement:** Use `ScrollController.animateTo` to scroll the active category pill into center view whenever `_activeCategory` changes.
- **User benefit:** The active category chip is always visible on screen without requiring manual horizontal scrolling.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_category_pills.dart:85`
- **Verification:** Swipe clock face to cycle through 10 categories; observe horizontal category strip smoothly gliding to center the selected chip.

---

### IMP-040: Home Minimal Toolbar Button Label Accessibility Scaling
- **Category:** Accessibility / Typography
- **Current behaviour:** In `lib/widgets/toolbar.dart:180-220`, toolbar action icon labels use fixed 10pt text. Under Android 200% system font scaling, text can clip outside button bounds.
- **Proposed improvement:** Wrap toolbar text in `FittedBox(fit: BoxFit.scaleDown)` with max lines 1 and dynamic textScaler clamping.
- **User benefit:** Button labels remain legible and never overlap or truncate awkwardly under maximum Android accessibility font settings.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/toolbar.dart:195`
- **Verification:** Set Android system font size to 2.0x (Maximum); inspect toolbar labels; confirm clean layout with zero text collisions.

---

### IMP-041: Sobriety Reset Confirmation Double-Lock Safeguard
- **Category:** Reliability / UX
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:637-650`, toggling "Mark as Relapse / Reset" activates the relapse flag immediately. Accidental clicks can cause panic for users with long streaks.
- **Proposed improvement:** Show an immediate alert dialog: `"Are you sure you want to log a streak reset? [Cancel] [Confirm Reset]"`.
- **User benefit:** Protects users in recovery from accidental or mis-tapped streak destructions.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/note_dialog.dart:645`
- **Verification:** Toggle relapse in note dialog; observe confirmation dialog requiring deliberate user confirmation.

---

### IMP-042: Clock Dial High-Contrast Pure Black/White Toggle
- **Category:** Visual Polish / Accessibility
- **Current behaviour:** In `lib/widgets/clock_face.dart:184-188`, `isContrastClock` relies on hardcoded checks against `#FFFFFF` and `#000000`. If an AMOLED theme user has a custom accent, the clock text defaults to colored accent numerals.
- **Proposed improvement:** Add an explicit setting toggle `Force Monochrome Clock Face` that renders pure high-contrast white (or black in light theme) regardless of selected accent color.
- **User benefit:** Gives minimalist users a classic luxury monochrome horology aesthetic.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/clock_face.dart:185`
- **Verification:** Enable Monochrome Clock in Display settings; verify digits render pure stark white even with Emerald or Ruby accent active.

---

### IMP-043: Dynamic Header Capsule Grace Days Bank Indicator Badge
- **Category:** Functional Intelligence / UX
- **Current behaviour:** When a user has banked grace days (streak shields), `DynamicHeaderCapsule` (`lib/widgets/dynamic_header_capsule.dart:72`) accepts `bankedGraceDays`, but only renders text in expanded mode.
- **Proposed improvement:** Render a miniature shield icon `🛡️ 2` in the resting pill when banked grace days are available.
- **User benefit:** Immediate reassurance of streak safety right from the resting home pill.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:150`
- **Verification:** Add 2 streak shields in settings; verify shield glyph and count render in the home header pill.

---

### IMP-044: Home Clock Complication Touch Target Expansion
- **Category:** Accessibility / Ergonomics
- **Current behaviour:** `HomeClockComplication` in `lib/widgets/home_clock_complication.dart:45-80` has an interactive hit box of 32x24dp, which is below the HIG minimum 44x44dp guideline.
- **Proposed improvement:** Wrap the complication in `ConstrainedBox(constraints: BoxConstraints(minWidth: 44.0, minHeight: 44.0))` with `HitTestBehavior.opaque`.
- **User benefit:** Flawless one-handed tapping without missing the complication button.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_clock_complication.dart:55`
- **Verification:** Tap slightly off-center on the clock complication; verify touch event is reliably captured.

---

### IMP-045: Instant Haptic Feedback on Quick Note Floating Button Press
- **Category:** Tactile Feedback
- **Current behaviour:** Tapping the quick note pen icon in `lib/widgets/toolbar.dart:120` opens the note sheet, but haptic feedback fires after modal route transition begins.
- **Proposed improvement:** Fire `AppHaptics.selection()` on `pointerDown` before route creation.
- **User benefit:** The app feels instantaneous and hardware-accelerated.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/toolbar.dart:122`
- **Verification:** Tap quick note icon; confirm tactile click occurs synchronously with touch down.

---

### IMP-046: Home Activity Ring Animation Smooth Interpolation on Moment Save
- **Category:** Visual Polish / Delight
- **Current behaviour:** When a new session or moment is logged, the activity ring painter snaps immediately to the new progress angle without animation.
- **Proposed improvement:** Animate the sweep angle from old value to new value over 400ms using `AnimationController` and `Curves.easeOutQuart`.
- **User benefit:** Rewarding visual feedback watching the ring expand as work is completed.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_activity_ring_painter.dart:55`
- **Verification:** Log a 1-hour session; watch the ring smoothly animate forward to the new total.

---

### IMP-047: Screen Reader Accessibility Trait on Live Clock Face
- **Category:** Accessibility / TalkBack
- **Current behaviour:** In `lib/widgets/clock_face.dart:239-242`, `Semantics(label: accessibleTimeLabel, excludeSemantics: true)` announces time every second if focused by TalkBack, creating a relentless audio chatter.
- **Proposed improvement:** Add `liveRegion: false` and only announce the time when the user deliberately focuses on or double-taps the clock face.
- **User benefit:** TalkBack users can navigate the screen comfortably without being interrupted every single second.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/widgets/clock_face.dart:240`
- **Verification:** Enable TalkBack; focus on home screen; confirm TalkBack does not chatter on second ticks unless the clock is actively focused.

---

### IMP-048: Two-Way Mode Pause/Resume State Color Morphing
- **Category:** Visual Polish
- **Current behaviour:** When pausing an ongoing session, the clock numerals change abruptly from `p.green` to `p.orange`.
- **Proposed improvement:** Animate color transitions using `ColorTween(begin: p.green, end: p.orange)` over 250ms.
- **User benefit:** Smooth visual state transition resembling Apple watchOS workout pauses.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/clock_face.dart:187`
- **Verification:** Tap Pause on an ongoing session; observe digits smoothly shift from emerald green to amber orange.

---

### IMP-049: Home Minimal Toolbar Blur Backplate Shadow Elevation
- **Category:** Visual Polish
- **Current behaviour:** `HomeMinimalToolbarCapsule` in `lib/widgets/home_minimal_toolbar_capsule.dart:35` has a hairline border but no drop shadow, causing it to visually merge into dense moment cards scrolling underneath.
- **Proposed improvement:** Add a subtle elevation shadow: `BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: Offset(0, 4))`.
- **User benefit:** Distinct layering separation between floating controls and underlying scrolling moments.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_minimal_toolbar_capsule.dart:38`
- **Verification:** Scroll text notes beneath the minimal toolbar capsule; verify clean visual depth separation.

---

### IMP-050: Ambient Sound Effect Mute on System Vibrate/Silent Mode
- **Category:** Android System Integration / Audio
- **Current behaviour:** In `lib/screens/note_kar_home.dart:139`, `_acousticFeedback` plays mechanical click sounds through `SoundPool` even when the Android device is switched to Silent or Do Not Disturb mode.
- **Proposed improvement:** Check Android `AudioManager.ringerMode` before triggering audio playback; silence clicks automatically if `RINGER_MODE_SILENT` or `RINGER_MODE_VIBRATE`.
- **User benefit:** Respects library, meeting, and quiet-zone etiquette automatically.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:180`
- **Verification:** Put phone on Silent mode; tap IN; verify sound is muted while haptic feedback operates normally.

---

### IMP-051: Session Start Time Rounding Option (5/10/15 Minutes)
- **Category:** Functional Intelligence
- **Current behaviour:** Sessions always start with millisecond timestamps (`14:23:41`). Many consultants and freelancers track time in clean 5, 10, or 15-minute billing increments.
- **Proposed improvement:** Add an optional setting `Snap Session Boundaries to 5/15 Minutes` that rounds start/end times to the nearest chosen interval.
- **User benefit:** Saves freelancers and professional users from having to manually edit timestamps for client billing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/note_kar_home.dart:1855`
- **Verification:** Enable 15-min snapping; tap IN at 14:07; verify session is cleanly logged as 14:00 or 14:15 per rounding rule.

---

### IMP-052: Home Pin Setup Overlay Number Shuffling Option for Shoulder-Surfing Defense
- **Category:** Security / Privacy
- **Current behaviour:** In `lib/widgets/home_pin_setup_overlay.dart:120-180`, the numeric keypad layout is always static (1-9, 0). Someone watching over the user's shoulder can deduce the PIN by finger position.
- **Proposed improvement:** Add an option `Scramble PIN Keypad on Entry` that randomizes button positions on each appearance.
- **User benefit:** Sovereign biometric and PIN security even in crowded public transit or office spaces.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_pin_setup_overlay.dart:130`
- **Verification:** Open PIN lock screen with scrambled mode on; verify numbers are placed in randomized positions each time.

---

### IMP-053: Automatic Screen Wake-Lock During Active Live Sessions Toggle
- **Category:** Android System Integration / Convenience
- **Current behaviour:** When studying or timing a presentation with NoteKar resting on a desk, the screen turns off based on the standard Android display timeout (e.g. 30 seconds).
- **Proposed improvement:** Add an optional toggle `Keep Screen Awake While Timing` that acquires `WAKELOCK` or `wakelock_plus` during an active session.
- **User benefit:** Users can use NoteKar as a dedicated desk chronometer or pomodoro timer without tapping the screen to prevent sleep.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1845`
- **Verification:** Enable feature; start session; let phone sit on desk for 2 minutes; confirm screen remains on.

---

### IMP-054: Horizontal Swipe Haptic Detent Resistance Curve
- **Category:** Visual Polish / Tactile Feedback
- **Current behaviour:** In `lib/screens/note_kar_home.dart:227-229`, `_horizontalSwipeDelta` accumulates linearly without rubber-band resistance when reaching the first or last category in the list.
- **Proposed improvement:** Apply Apple-style asymptotic rubber-band damping (`delta = delta * 0.45 / (1.0 + delta.abs() * 0.005)`) when pulling past list boundaries.
- **User benefit:** Satisfying physical resistance feeling when reaching the edge of the category collection.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/screens/note_kar_home.dart:228`
- **Verification:** Swipe clock past the final category; observe physical rubber-band drag resistance.

---

### IMP-055: Home Clock Complication Battery Level Indicator
- **Category:** Functional Intelligence
- **Current behaviour:** The clock complication shows either date or streak count.
- **Proposed improvement:** Add an optional complication slot showing device battery level with color-coded battery health indicator.
- **User benefit:** Turns the life ledger clock into an all-in-one glanceable executive instrument.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/widgets/home_clock_complication.dart:60`
- **Verification:** Select Battery complication; verify live battery percentage renders cleanly beneath time.

---

### IMP-056: Quick Action Note Input Field Auto-Capitalization Sentences
- **Category:** User Flows / Typography
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:580`, `TextField` uses default text capitalization. On some OEM keyboards, first words of subsequent sentences are not capitalized.
- **Proposed improvement:** Explicitly set `textCapitalization: TextCapitalization.sentences`.
- **User benefit:** Fast, grammatically clean note taking without manually tapping Shift on the software keyboard.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/note_dialog.dart:582`
- **Verification:** Type "hello. world." in quick note; verify "world" automatically begins with capital "W".

---

### IMP-057: Home Session Timer Microsecond Jitter Elimination
- **Category:** Performance / Typography
- **Current behaviour:** When duration elapsed is calculated (`lib/widgets/clock_face.dart:75`), if the OS timer fires with millisecond variance, text widths can flicker microscopically if font kerning varies.
- **Proposed improvement:** Wrap time strings in `SizedBox` with fixed monospaced character widths derived from `NkTokens.typography`.
- **User benefit:** Zero visual vibration of elapsed counter numerals.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/clock_face.dart:248`
- **Verification:** Watch a session tick for 60 seconds; verify digits remain rock-still in 2D space.

---

### IMP-058: App Icon Style Switching Progress Indicator
- **Category:** User Flows / Visual Polish
- **Current behaviour:** Switching launcher icons in `lib/dialogs/settings/app_icons_settings_page.dart:110` calls `PackageManager.setComponentEnabledSetting`, which can take 300-800ms. The UI provides no micro-spinner during the channel call.
- **Proposed improvement:** Show a 16dp `CircularProgressIndicator` inside the selected icon chip while `_appIconChangeInFlight` is true.
- **User benefit:** Clear visual confirmation that the OS icon alias change is taking place.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/app_icons_settings_page.dart:125`
- **Verification:** Tap 'Icon Gold'; observe smooth spinner until Android package manager confirms alias switch.

---

### IMP-059: Dynamic Header Capsule Drag Resistance Threshold
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** In `lib/widgets/dynamic_header_capsule.dart:90`, any vertical drag of 5dp begins expanding the card, triggering accidental expansions while scrolling down.
- **Proposed improvement:** Increase the expansion threshold to 24dp vertical displacement with velocity check.
- **User benefit:** Eliminates accidental capsule expansions while casually scrolling the timeline.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:92`
- **Verification:** Scroll slowly past the header; verify capsule does not jitter or expand unintentionally.

---

### IMP-060: Home Toolbar Voice Note Waveform Real-Time Decibel Metering
- **Category:** Perceived Quality / Visual Polish
- **Current behaviour:** During voice recording in `lib/widgets/toolbar.dart:320-335`, the waveform bars oscillate using static random factors rather than true hardware microphone amplitude.
- **Proposed improvement:** Bind the 7 waveform bars directly to `AudioService.instance.currentRecordingAmplitude` (linear decibel map `0.0 - 1.0`).
- **User benefit:** Authentic visual feedback reflecting real voice pitch and room volume.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/toolbar.dart:325`
- **Verification:** Speak loudly, then whisper; watch the toolbar waveform bars scale proportionally to real acoustic amplitude.

---

### IMP-061: Quick Note Dialog Keyboard Dismiss on Outer Drag Down
- **Category:** User Flows / UX
- **Current behaviour:** When `NoteDialog` is open, dragging down on the header row does not dismiss the keyboard or sheet unless dragging specifically on the top margin.
- **Proposed improvement:** Wrap sheet content in `GestureDetector(onVerticalDragUpdate: ...)` that dismisses keyboard when downward drag velocity exceeds 300dp/s.
- **User benefit:** Natural, fluid dismissal gesture matching iMessage and WhatsApp sheets.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_dialog.dart:450`
- **Verification:** Swipe down anywhere on the note dialog header; observe soft keyboard dismiss instantly.

---

### IMP-062: Home Screen Empty State "Log First Moment" Guided Touch Ripple
- **Category:** Onboarding / Delight
- **Current behaviour:** On fresh install with zero moments, the empty timeline shows text guidance but no visual directional cue pointing to the IN button.
- **Proposed improvement:** Add a gentle glowing pulse animation around the IN button or action toolbar during zero-state.
- **User benefit:** Guides first-time users directly to the primary action without reading paragraphs of help text.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1250`
- **Verification:** Launch clean install; observe subtle breathing halo highlighting the IN button.

---

### IMP-063: Midnight Transition Auto-Refresh of Day Timeline Without Screen Restart
- **Category:** Reliability / Architecture
- **Current behaviour:** If NoteKar remains open on the desk past 00:00:00 midnight, the date header and daily groupings continue displaying "Today" for yesterday until the user navigates away and back.
- **Proposed improvement:** In `LiveClockFace._scheduleNextTick()`, when `now.day != _now.day`, dispatch a `dayBoundaryCrossed` event that silently rebuilds the day grouping headers.
- **User benefit:** Timelines, date headers, and midnight statistics stay 100% accurate without requiring manual app reloads.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/screens/note_kar_home.dart:105`
- **Verification:** Set mock system clock to 23:59:58; wait 3 seconds; verify "Today" shifts to the new calendar day instantly.

---

### IMP-064: Dynamic Header Intentionality Ratio Tooltip Calculation Explanation
- **Category:** Discoverability / UX
- **Current behaviour:** The capsule displays `78% Intentional`. Users often wonder what "Intentional" means or how the percentage was computed.
- **Proposed improvement:** Tapping the percentage badge displays a micro-popover: `"Intentionality: Ratio of time logged under your defined Goals vs untargeted intervals."`.
- **User benefit:** Transparent metrics that educate users on how to improve their daily focus score.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:190`
- **Verification:** Tap the intentionality % chip; verify clear explanation tooltip appears.

---

### IMP-065: Home Minimal Toolbar One-Handed Left/Right Alignment Setting
- **Category:** Ergonomics / Personalization
- **Current behaviour:** Floating controls in `HomeMinimalToolbarCapsule` are always centered. On large 6.8" devices (Pixel Pro, Galaxy Ultra), reaching across with one hand can cause thumb strain.
- **Proposed improvement:** Add an option `Toolbar Alignment: Center | Left (Left-Handed) | Right (Right-Handed)` that biases floating button layout by 24dp toward the preferred edge.
- **User benefit:** True one-handed accessibility on today's massive flagship devices.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_minimal_toolbar_capsule.dart:55`
- **Verification:** Switch to Left-Handed mode in settings; verify floating action buttons shift comfortably into left thumb reach.

---

### IMP-066: Clock Complication Double-Tap Direct Mode Switch
- **Category:** User Flows / Shortcuts
- **Current behaviour:** `HomeClockComplication` only supports single tap.
- **Proposed improvement:** Add double-tap gesture support to toggle between 1-Way and 2-Way recording modes instantly.
- **User benefit:** Power users can switch logging workflows in 0.2 seconds without opening the mode sheet.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_clock_complication.dart:72`
- **Verification:** Double-tap clock complication; verify mode switches cleanly with a distinct double-click haptic.

---

### IMP-067: Active Session Duration Notification Click Intent Routing
- **Category:** Android System Integration / UX
- **Current behaviour:** Clicking on the Android floating timer notification simply launches `MainActivity` to the root route without focusing on the active session.
- **Proposed improvement:** Pass `EXTRA_FOCUS_ACTIVE_SESSION = true` in the notification PendingIntent; on launch, scroll timeline smoothly to the top active session card.
- **User benefit:** Immediate direct focus on what the user clicked.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:85`
- **Verification:** Click active timer notification; verify app opens and brings the live active card into immediate view.

---

### IMP-068: In-App PIN Setup Overlay Success Confetti Celebration
- **Category:** Perceived Quality / Delight
- **Current behaviour:** When a new PIN is successfully saved in `HomePinSetupOverlay` (`lib/widgets/home_pin_setup_overlay.dart:210`), the overlay simply disappears.
- **Proposed improvement:** Trigger a light 300ms green checkmark pulse with `HapticFeedback.heavyImpact()` before closing.
- **User benefit:** Satisfying psychological confirmation that security has been successfully locked down.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_pin_setup_overlay.dart:225`
- **Verification:** Set up a PIN; observe crisp tactile pulse and visual checkmark confirmation before sheet dismisses.

---

### IMP-069: Home Screen Momentum Card Trend Delta Indicator
- **Category:** Functional Intelligence
- **Current behaviour:** `HomeMomentumCard` shows today's hours (e.g. `4.2h`), but doesn't tell the user whether they are ahead of or behind yesterday's pace.
- **Proposed improvement:** Add a compact delta pill: `↑ +1.2h vs yesterday` in green or `↓ -0.8h vs yesterday` in subtle text2.
- **User benefit:** Instant historical context to motivate daily consistency.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_momentum_card.dart:90`
- **Verification:** Log moments today; verify trend delta pill compares accurately against yesterday's logged duration.

---

### IMP-070: Clock Font BebasNeue Optical Vertical Centering
- **Category:** Visual Polish / Typography
- **Current behaviour:** Due to standard BebasNeue font ascender/descender metrics, the numerals sit slightly high within the baseline bounding box compared to standard system fonts.
- **Proposed improvement:** Add a font-specific optical offset `Transform.translate(offset: Offset(0, isBebas ? 2.5 : 0.0))` to achieve true optical vertical centering.
- **User benefit:** Pixel-perfect vertical balance on the home clock face.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/widgets/clock_face.dart:250`
- **Verification:** Compare BebasNeue against Inter; verify both visually align to the exact optical center of the card.

---

### IMP-071: Home Activity Ring Segmented Category Color Arcs
- **Category:** Visual Polish / Functional
- **Current behaviour:** `HomeActivityRingPainter` renders a single unified arc in `p.accent`.
- **Proposed improvement:** Segment the arc into proportional colored slices matching the categories logged today (e.g., Blue for Work, Purple for Deep Focus, Amber for Study).
- **User benefit:** Apple Watch Activity-style glanceability: immediately see how time was divided between life areas.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_activity_ring_painter.dart:65`
- **Verification:** Log 2 hours of Work and 1 hour of Study; verify ring displays proportional blue and amber arcs.

---

### IMP-072: Sobriety Streak Card Reset Reason Quick-Tagging
- **Category:** Functional / UX
- **Current behaviour:** Resetting a sobriety streak resets the counter with a basic note, but lacks structured categorisation for triggers.
- **Proposed improvement:** When logging a reset, provide quick one-tap trigger tags: `[Urge / Craving]`, `[Stress / Work]`, `[Social Pressure]`, `[Fatigue]`.
- **User benefit:** Empowers users in recovery to identify recurrence patterns and trigger correlations over time.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_dialog.dart:660`
- **Verification:** Tap reset toggle; observe structured recovery trigger chips appear for rapid selection.

---

### IMP-073: Zen Day Gauge Twilight Transition Smooth Color Shading
- **Category:** Visual Polish
- **Current behaviour:** `ZenDayGauge` (`lib/widgets/zen_day_gauge.dart:60-80`) switches between day and night palettes abruptly at 18:00.
- **Proposed improvement:** Introduce a 1-hour twilight blend window (`17:30 - 18:30`) using linear color lerping between golden amber and deep twilight indigo.
- **User benefit:** Breathtaking atmospheric visual polish celebrating dusk and dawn transitions.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/zen_day_gauge.dart:70`
- **Verification:** Set clock to 18:00; observe warm golden twilight gradient on the gauge track.

---

### IMP-074: Home Screen Pull-to-Refresh Silent Database Verification
- **Category:** Reliability / Architecture
- **Current behaviour:** Swiping down at the top of the home timeline performs no action.
- **Proposed improvement:** Add a subtle `CustomScrollView` pull-to-refresh that triggers a silent Isar database integrity check and refreshes cache indices, showing a delicate spinner with haptic tick.
- **User benefit:** User peace of mind: quick tactile gesture to verify that everything is safely written to disk.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1320`
- **Verification:** Pull down on home screen; feel gentle haptic tick and see confirmation indicator that database is synchronized.

---

### IMP-075: Dynamic Header Capsule Goal Pacing Progress Line
- **Category:** Functional Intelligence
- **Current behaviour:** When a goal is selected in `DynamicHeaderCapsule`, it shows target hours, but not the expected pacing position for this hour of the day.
- **Proposed improvement:** Render a miniature 2dp pacing marker dot on the goal progress track showing where the user should be by this time of day.
- **User benefit:** Immediate awareness whether the user is on track, ahead, or behind their scheduled daily pacing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:340`
- **Verification:** Set daily goal of 8 hours; at 12:00 PM verify pacing dot sits at exactly 50% along the track.

---

### IMP-076: Minimal Moment Mode Elimination of Empty Rows
- **Category:** Visual Polish / Ergonomics
- **Current behaviour:** When `_minimalMomentOptions` is enabled in settings, cards hide icons but leave generous vertical margins matching standard cards.
- **Proposed improvement:** Tighten vertical card padding from 14dp down to 8dp and reduce gutter spacing, increasing information density by 35%.
- **User benefit:** Power users can view 8-10 moments on a single screen without scrolling.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_single_tile.dart:74`
- **Verification:** Enable Minimal Moment Options; verify timeline cards pack together compactly and cleanly.

---

### IMP-077: Checkpoints Quick Bar Completed Habit Confetti Sparkle
- **Category:** Perceived Quality / Delight
- **Current behaviour:** Tapping a habit in `CheckpointsQuickBar` marks it complete with a standard checkmark change.
- **Proposed improvement:** Fire a localized micro-burst particle sparkle (12 colorful particles over 400ms) with `AppHaptics.success()`.
- **User benefit:** High sensory gratification for daily routine execution.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart:120`
- **Verification:** Check off "Morning Walk"; watch delightful micro-sparkle explode gently from the chip.

---

### IMP-078: Home Clock Complication Weather / Temperature Slot Option
- **Category:** Functional Intelligence
- **Current behaviour:** Complications cannot display ambient outdoor temperature.
- **Proposed improvement:** Add support for local offline temperature display or manual climate entry to log environmental context alongside productivity.
- **User benefit:** Track how temperature and seasonal weather affect focus and energy levels.
- **Implementation effort:** 3
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/widgets/home_clock_complication.dart:90`
- **Verification:** Select Climate complication; verify clean temperature badge appears on the dial.

---

### IMP-079: Android 15 Edge-to-Edge System Bar Inset Guard
- **Category:** Android System Integration / Compatibility
- **Current behaviour:** In `lib/main.dart:133-142`, `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` is declared, but on Android 15 (API 35) gesture navigation handles can overlap bottom modal sheet buttons if padding is not dynamically derived from `MediaQuery.viewPadding.bottom`.
- **Proposed improvement:** Ensure all bottom buttons in `AppSheet` and `NoteDialog` strictly enforce `EdgeInsets.only(bottom: math.max(media.viewPadding.bottom, 16.0))`.
- **User benefit:** Zero accidental gesture navigation triggers when tapping bottom sheet buttons on Android 15.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/app_sheet.dart:110`
- **Verification:** Test on Android 15 emulator with gesture nav; verify 16dp clearance above the home pill bar.

---

### IMP-080: Rapid Mode Switching Keyboard Shortcut via Bluetooth Keyboards
- **Category:** Accessibility / Power Users
- **Current behaviour:** When a tablet or foldable phone is docked with a physical Bluetooth keyboard, pressing keys does nothing on the home screen.
- **Proposed improvement:** Add keyboard shortcuts (`Space` to Start/Stop session, `M` to cycle modes, `N` to open quick note, `H` to open history).
- **User benefit:** Lightning-fast desktop/tablet productivity for keyboard power users.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/note_kar_home.dart:580`
- **Verification:** Connect Bluetooth keyboard; press Spacebar; confirm active session starts immediately.

---

### IMP-081: Home Minimal Toolbar Pill Floating Magnet Snap Animation
- **Category:** Visual Polish
- **Current behaviour:** `HomeMinimalToolbarCapsule` stays rigidly in place regardless of list scroll direction.
- **Proposed improvement:** On downward scroll, subtly translate the toolbar 6dp down with `Curves.easeOutCubic`; on upward scroll, snap back smoothly into resting position.
- **User benefit:** Sophisticated dynamic presence that yields space to reading content.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_minimal_toolbar_capsule.dart:45`
- **Verification:** Scroll timeline up and down; observe gentle organic breathing translation of the capsule.

---

### IMP-082: Sound Effect Click Volume Normalization
- **Category:** Audio / Polish
- **Current behaviour:** In `MainActivity.kt:185`, sound pool playback uses `soundPool.play(soundId, 1.0f, 1.0f, 0, 0, 1.0f)`, which can be piercingly loud through studio headphones.
- **Proposed improvement:** Cap maximum sound pool volume at `0.45f` and allow user volume tuning in Sound settings.
- **User benefit:** Pleasant, soft mechanical clicks that never startle headphone users.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:185`
- **Verification:** Wear earphones; tap buttons; verify sound is warm, quiet, and unobtrusive.

---

### IMP-083: Clock Face Tap Ripple Expansion Center Alignment
- **Category:** Visual Polish
- **Current behaviour:** In `lib/screens/note_kar_home.dart:223`, `_lastTapPosition` stores the tap coordinate, but the ink ripple expands from the center of the bounding box rather than the exact touch point.
- **Proposed improvement:** Feed `_lastTapPosition` directly into `InkFeature` or custom radial shader origin.
- **User benefit:** Realistic radial energy wave propagating outward directly from beneath the user's fingertip.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/screens/note_kar_home.dart:225`
- **Verification:** Tap the upper-right corner of the clock; see ripple emanate directly from the exact touch origin.

---

### IMP-084: Zen Day Gauge Lunar Phase Integration
- **Category:** Delight / Visual Polish
- **Current behaviour:** During nighttime hours, `ZenDayGauge` renders a generic moon.
- **Proposed improvement:** Calculate true astronomical moon phase (New, Waxing Crescent, Full, Waning) based on calendar date and render the actual current lunar phase.
- **User benefit:** Poetic and mindful connection with natural cosmic cycles.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/widgets/zen_day_gauge.dart:82`
- **Verification:** Check gauge during Full Moon; verify full glowing lunar disc is rendered.

---

### IMP-085: Active Session Ongoing Pulse Haptic Heartbeat Option
- **Category:** Accessibility / Tactile Feedback
- **Current behaviour:** Once a session starts, there is no physical reminder running. Blind or visually impaired users cannot feel if a session is actively timing.
- **Proposed improvement:** Add an optional `Tactile Heartbeat Every 15 Minutes` setting that fires a soft double-pulse haptic (`AppHaptics.tick()`) at 15-minute intervals.
- **User benefit:** Invaluable temporal awareness for visually impaired users without looking at the screen.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1840`
- **Verification:** Enable Tactile Heartbeat; run session; verify soft double-vibration at the 15-minute mark.

---

### IMP-086: Home Screen Category Pill Deletion Safety Shield
- **Category:** Reliability / Data Safety
- **Current behaviour:** Deleting a category in `CategoryService` can leave moments tagged with an orphaned category string.
- **Proposed improvement:** When deleting a category, prompt the user: `"Move existing moments to 'All' or delete with category?"`.
- **User benefit:** Prevents accidental loss of historical category associations.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/utils/category_service.dart:140`
- **Verification:** Delete category with 12 moments; verify option to reassign to 'All' preserves all moments.

---

### IMP-087: Dynamic Header Capsule Drag Dismiss Velocity Memory
- **Category:** Visual Polish
- **Current behaviour:** If the user drags the expanded header capsule halfway and lets go, it occasionally snaps in the opposite direction of their gesture flick.
- **Proposed improvement:** Track `dragVelocity.pixelsPerSecond.dy`: if velocity is negative, always collapse; if positive, always expand.
- **User benefit:** Natural, predictable physics that never fight against the user's gesture direction.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:102`
- **Verification:** Drag up quickly from bottom; verify card collapses cleanly regardless of distance traveled.

---

### IMP-088: Two-Way Mode Session Lap Split Marker
- **Category:** Functional Intelligence
- **Current behaviour:** Two-Way mode only supports Start and End. There is no concept of sub-phases or split laps (e.g. Phase 1 Research, Phase 2 Writing).
- **Proposed improvement:** Add a "Split Lap" button during active sessions that logs an interim timestamped checkpoint moment without terminating the continuous chronometer.
- **User benefit:** Seamless sub-task breakdown inside long multi-hour work sessions.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:1870`
- **Verification:** Start session, tap Split Lap after 20 mins; observe lap moment recorded while continuous session timer keeps ticking.

---

### IMP-089: Home Screen Battery Drain Defense via Idle Sensor Disconnect
- **Category:** Performance / Battery Optimization
- **Current behaviour:** If NoteKar remains in the foreground while the phone is locked, sensor listeners might stay active on some Android versions.
- **Proposed improvement:** Pause accelerometer and sensor subscriptions inside `WidgetsBindingObserver.didChangeAppLifecycleState` immediately when state is `inactive` or `paused`.
- **User benefit:** Zero standby battery drain when the phone is locked in the pocket.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/screens/note_kar_home.dart:315`
- **Verification:** Lock phone while on home screen; verify ADB sensor dumps show 0 active sensor listeners.

---

### IMP-090: Home Screen Swipe Direction Mirroring for RTL Locales (Arabic/Hebrew)
- **Category:** Accessibility / Internationalization
- **Current behaviour:** Horizontal clock swipe in `lib/screens/note_kar_home.dart:257-293` is hardcoded: swiping left always calls `_onNextGoal()`. In RTL languages, swiping left should logically navigate to the previous category.
- **Proposed improvement:** Check `Directionality.of(context) == TextDirection.rtl` and invert swipe direction logic accordingly.
- **User benefit:** Natural, culturally intuitive navigation for millions of RTL language users worldwide.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:260`
- **Verification:** Set locale to Arabic or Hebrew; swipe left; verify it cycles to the preceding category as expected in RTL.

---

### IMP-091: Clock Face Digit Morphing Animation Between Modes
- **Category:** Visual Polish / Delight
- **Current behaviour:** When switching from 2-Way session timer (`01:24.30`) to Live Clock (`14:24.30`), the numbers replace instantly.
- **Proposed improvement:** Use `AnimatedSwitcher` with a gentle slide-and-fade transition (`duration: 200ms`, `NkCurves.springSnappy`).
- **User benefit:** Elegant visual continuity when transitioning between clock mode and chronometer mode.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/clock_face.dart:245`
- **Verification:** End an active session; observe chronometer digits glide smoothly into live clock time.

---

### IMP-092: Home Screen Minimal Toolbar Icon Contrast Check in E-Ink Theme
- **Category:** Accessibility / Visual Polish
- **Current behaviour:** In the high-contrast `eink` theme, toolbar icons use standard alpha transparencies (`withValues(alpha: 0.6)`), which look washed out or grey on electronic paper displays.
- **Proposed improvement:** When `p.name == 'eink'`, force all icons and borders to pure 100% solid black `#000000`.
- **User benefit:** Crystal-clear contrast on Boox, Kindle, and E-Ink Android devices.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/toolbar.dart:185`
- **Verification:** Select E-Ink theme in display settings; verify all toolbar glyphs render with 100% stark black ink.

---

### IMP-093: Checkpoints Quick Bar Overflow Indicators
- **Category:** Visual Polish / Discoverability
- **Current behaviour:** If a user has 10 habits, only 4 are visible on screen. There is no subtle gradient fade indicating that more habits exist off-screen to the right.
- **Proposed improvement:** Add a 16dp horizontal trailing gradient fade (`ShaderMask`) on the right edge that disappears when scrolled to the end.
- **User benefit:** Obvious visual hint that more habit items are ready to be scrolled into view.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart:60`
- **Verification:** Inspect habit quick bar with 8 items; see soft trailing fade cueing scrollability.

---

### IMP-094: Home Screen Double-Tap Clock Face Quick Manual Entry Shortcut
- **Category:** User Flows / Shortcuts
- **Current behaviour:** Double-tapping the large clock face currently does nothing.
- **Proposed improvement:** Double-tapping the clock face opens the "Log Past Moment" manual entry sheet prefilled with the current time.
- **User benefit:** Instant access to manual retroactive logging without navigating into history.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:850`
- **Verification:** Double-tap center of clock; verify Manual Entry sheet opens with current hour pre-selected.

---

### IMP-095: In-App PIN Setup Overlay Fingerprint Biometric Prompt Trigger
- **Category:** Security / Convenience
- **Current behaviour:** When unlocking the app, if PIN is active, the custom PIN pad displays first, requiring an extra tap to trigger fingerprint scanning.
- **Proposed improvement:** Automatically invoke native Android biometric prompt (`BiometricPrompt`) synchronously on screen appearance when system lock is enabled.
- **User benefit:** Instant 0.1-second unlock simply by placing thumb on the hardware sensor.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/privacy_overlay.dart:95`
- **Verification:** Lock app, reopen; verify fingerprint scanner hardware dialog pops up immediately.

---

### IMP-096: Home Screen Category Pill Counter Badge
- **Category:** Functional Intelligence
- **Current behaviour:** Category pills show title only (e.g. `Deep Focus`). Users cannot see how many moments have been logged in that category today.
- **Proposed improvement:** Add an optional micro-badge: `Deep Focus (3)` displaying today's count in 10pt tabular figures.
- **User benefit:** Immediate feedback on daily habit frequency across categories.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/home_category_pills.dart:125`
- **Verification:** Log 2 moments in Work; observe `Work (2)` badge in the category pill bar.

---

### IMP-097: Dynamic Header Capsule Today's Milestone Mini-Indicator
- **Category:** Delight / Visual Polish
- **Current behaviour:** When a milestone is reached today, it can only be seen in the full celebration dialog.
- **Proposed improvement:** Render a miniature star or laurel glyph `★ 100d` inside the resting dynamic header pill on milestone days.
- **User benefit:** Sustained sense of daily pride every time the user checks the time.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart:165`
- **Verification:** Reach milestone; observe commemorative laurel badge inside the resting header pill.

---

### IMP-098: Voice Quick Recording Maximum Duration Safety Cap & Auto-Save
- **Category:** Reliability / Data Safety
- **Current behaviour:** If a user accidentally starts a voice recording in their pocket and leaves it running, it could record for hours until device storage fills up.
- **Proposed improvement:** Enforce a maximum voice recording limit of 30 minutes; automatically stop and save the audio when the limit is reached, with a notification alert.
- **User benefit:** Prevents storage exhaustion and device overheating from runaway recordings.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_dialog.dart:230`
- **Verification:** Let voice recording run past 30 minutes (or test with 1-minute mock threshold); verify auto-save occurs safely.

---

### IMP-099: Clock Face Seconds Color Dimming Contrast Compliance
- **Category:** Accessibility / Visual Polish
- **Current behaviour:** In `lib/widgets/clock_face.dart:203`, `secondsColor` when unhighlighted is `clockColor.withValues(alpha: 0.38)`. In Light theme, this fails the 3:1 contrast ratio against light grey backgrounds.
- **Proposed improvement:** In light themes, raise unhighlighted seconds alpha to `0.55` to guarantee compliance with WCAG AA accessibility standards.
- **User benefit:** Crisp legibility for elderly users and outdoors under direct sunlight.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/clock_face.dart:203`
- **Verification:** Switch to Light theme under direct bright light; confirm unhighlighted seconds are clearly legible.

---

### IMP-100: Home Screen First-Frame Cold Start Painting Optimization
- **Category:** Performance / Startup Time
- **Current behaviour:** In `lib/main.dart:110-116`, multiple asynchronous services are initialized before UI mounting. While safe, heavy disk lookups can add 120ms to initial frame delivery.
- **Proposed improvement:** Mount the initial `ClockFace` skeleton on frame 1 while lazy-loading secondary history lists on frame 2 via `addPostFrameCallback`.
- **User benefit:** Instantaneous cold-start launch experience feeling snappy and responsive.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/main.dart:112`
- **Verification:** Measure cold start TTID (Time To Initial Display) via ADB; observe a 110ms reduction in startup latency.
