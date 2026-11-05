# NoteKar 500+ Micro-Improvements Inventory: Part 3
## Focus Area: Habit Checkpoints, Consistency Dashboard, Targets & Goals, Projects, Sobriety Companion, Urge Surfing & Milestones
### Items: IMP-201 to IMP-300

---

### IMP-201: Checkpoints Dashboard 7-Day Matrix Weekday Alignment
- **Category:** Visual Polish / Calendar
- **Current behaviour:** In `lib/screens/checkpoints_dashboard_screen.dart:210-250`, the 7-day completion matrix dots are displayed as generic circles without showing weekday initials (`M T W T F S S`) above columns.
- **Proposed improvement:** Add an overline row of subtle 10pt weekday initials (`M`, `T`, `W`, `T`, `F`, `S`, `S`) with today's column underlined with a 2dp accent bar.
- **User benefit:** Instant temporal clarity regarding which specific days were missed without mental counting.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:225`
- **Verification:** Inspect habit card in Checkpoints Dashboard; verify clear weekday column headers with today's column highlighted.

---

### IMP-202: Urge Surfing Box Breathing Vibration Waveform Guidance
- **Category:** Tactile Feedback / Mindfulness
- **Current behaviour:** In `lib/dialogs/urge_surfing_dialog.dart:90-115`, box breathing only pulses a light vibration on phase boundaries (Inhale, Hold, Exhale, Hold). Eyes-closed users receive no feedback during the 4-second hold or exhale sweep.
- **Proposed improvement:** Provide gentle continuous haptic ramp: rising micro-pulses during 4s Inhale, steady stillness during Hold, and descending micro-pulses during Exhale.
- **User benefit:** Complete eyes-closed mindful urge surfing: users can ground themselves during overwhelming cravings without looking at the screen.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:95`
- **Verification:** Start urge surfing; close eyes; feel the rising and falling tactile breath guidance through the 4-phase cycle.

---

### IMP-203: Goals Sheet Target Allocation Daily Deficit Breakdown
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/dialogs/goals_sheet.dart:180-220`, weekly targets display total hours remaining (e.g. `12 hours to go`). It doesn't break down how many hours are needed per remaining day of the week.
- **Proposed improvement:** Add a dynamic pacing calculation: `"12h to go • 2.4h/day needed over remaining 5 days"`.
- **User benefit:** Makes large weekly or monthly targets immediately actionable and realistic.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:195`
- **Verification:** Set 20-hour weekly target; log 5 hours on Tuesday; verify sheet displays exact daily hours required for Wed-Sun.

---

### IMP-204: Checkpoint Session Sheet Quick Duration Chips Customization
- **Category:** Personalization / Convenience
- **Current behaviour:** In `lib/dialogs/checkpoint_session_sheet.dart:81`, `_quickDurations` is hardcoded to `[15, 30, 45, 60, 90, 120]`. Quick 5-minute habits (flossing, vitamins, pushups) have no suitable chip.
- **Proposed improvement:** Dynamically adjust quick duration chips based on habit preset category: micro-habits show `[5, 10, 15, 20, 30]` while deep focus presets show `[30, 45, 60, 90, 120]`.
- **User benefit:** Realistic 1-tap logging durations for micro-habits without manually dragging time drum pickers.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:81`
- **Verification:** Open session logger for 'Flossing'; verify 5m and 10m quick chips appear first.

---

### IMP-205: Sobriety Companion Milestone Celebration Shareable Card Export
- **Category:** Delight / Social Sharing
- **Current behaviour:** In `lib/widgets/milestone_celebration_dialog.dart:85-110`, celebrating a sobriety milestone displays confetti, but tapping the share button shares plain text.
- **Proposed improvement:** Generate a gorgeous, private Apple HIG milestone badge graphic card (`ShareableMilestoneSheet`) with custom gradient background and sovereign badge graphics.
- **User benefit:** Beautiful, dignified visual artifact users can privately save to camera roll or share with support sponsors.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/shareable_milestone_sheet.dart:45`
- **Verification:** Unlock 30-day sobriety milestone; tap Share; observe rendered high-res badge card ready for saving or export.

---

### IMP-206: Habit Checkpoint Consistency Score Standard Deviation Tooltip
- **Category:** Discoverability / Math Transparency
- **Current behaviour:** In `lib/screens/checkpoints_dashboard_screen.dart:90-100`, `CheckpointStats` computes timing standard deviation `±σ` (e.g. `±42m`), but users have no explanation of what `±42m` means.
- **Proposed improvement:** Tapping the `±σ` badge opens a micro-sheet: `"Timing Variance: You perform this habit within 42 minutes of your average time 68% of the time. Lower variance means stronger routine automation."`.
- **User benefit:** Clear, empowering behavioral science insight that encourages building unbreakable routine clocks.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:95`
- **Verification:** Tap `±35m` on morning workout card; see clear explanation of behavioral timing variance.

---

### IMP-207: Projects Sheet Milestone Checkbox Confetti Micro-Burst
- **Category:** Delight / Micro-Interaction
- **Current behaviour:** In `lib/dialogs/projects_sheet.dart:180-220`, completing a project milestone checkbox ticks the box statically.
- **Proposed improvement:** Trigger a localized 300ms emerald confetti burst and `AppHaptics.success()` when a milestone checkbox is completed.
- **User benefit:** Satisfying dopamine reinforcement for finishing project deliverables.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/projects_sheet.dart:195`
- **Verification:** Check off milestone in active project; observe crisp tactile click and mini celebratory sparkle.

---

### IMP-208: 5-4-3-2-1 Sensory Grounding Audio Chime on Step Progression
- **Category:** Audio / Mindfulness
- **Current behaviour:** In `lib/dialogs/urge_surfing_dialog.dart:34-42`, progressing through the 5 grounding steps (See, Touch, Hear, Smell, Taste) updates text silently.
- **Proposed improvement:** Play a gentle, meditative Tibetan singing bowl chime (soft acoustic bell) as each sensory anchor is acknowledged.
- **User benefit:** Calming acoustic anchor that helps deactivate sympathetic nervous system fight-or-flight arousal.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:38`
- **Verification:** Tap through grounding steps 5 -> 4 -> 3; hear soothing harmonic chime accompany each step transition.

---

### IMP-209: Goals Sheet Direct 1-Tap Session Start Shortcut
- **Category:** User Flows / Efficiency
- **Current behaviour:** In `lib/dialogs/goals_sheet.dart:250-280`, starting a session for a goal requires closing the sheet, finding the category on the home screen, and tapping IN.
- **Proposed improvement:** Add a prominent "Start Session Now" button directly on each goal card in `GoalsSheet` that starts the session immediately and closes the sheet.
- **User benefit:** Eliminates 3 friction taps: pick a goal and start working instantly.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/goals_sheet.dart:260`
- **Verification:** Open Goals Sheet; tap 'Start Session' on 'Q4 Roadmap'; verify session begins immediately on home screen.

---

### IMP-210: Add/Edit Habit Sheet Popular Emoji Quick-Grid Auto-Filtering
- **Category:** UX / Polish
- **Current behaviour:** In `lib/dialogs/add_edit_habit_sheet.dart:56-74`, the popular emoji grid is static. If a user types "Water" in the title, the emoji field remains `🎯`.
- **Proposed improvement:** Auto-detect title keywords: typing "Water" suggests `💧`, "Run" suggests `🏃`, "Read" suggests `📖`, "Sleep" suggests `🌙`.
- **User benefit:** Intuitive, delightful convenience that eliminates emoji searching.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:95`
- **Verification:** Type "Morning Coffee" into habit title; verify `☕` is automatically pre-selected in emoji box.

---

### IMP-211: Sobriety Companion Relapse Recovery Supportive Message Card
- **Category:** Empathy / UX
- **Current behaviour:** Logging a relapse resets the streak to 0 with neutral clinical text.
- **Proposed improvement:** Display an empathetic, psychologically grounded recovery card inspired by cognitive behavioral therapy: `"A reset is not failure. You built 42 days of neural rewiring. Those days do not disappear. Take a deep breath and begin again."`.
- **User benefit:** Prevents shame spiraling and gives compassionate encouragement to restart immediately.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/note_dialog.dart:655`
- **Verification:** Log a streak reset; confirm compassionate resilience message displays with a grounding breath option.

---

### IMP-212: Checkpoints Dashboard "Best Time to Log" Predictive AI Recommendation
- **Category:** Functional Intelligence
- **Current behaviour:** Checkpoints show target time, but don't compute when the user actually performs the habit with highest historical success.
- **Proposed improvement:** Compute the median completion window over the last 60 days: `"Your optimal rhythm is 07:15 AM (92% completion rate)"`.
- **User benefit:** Helps users align their target goals with their true biological circadian rhythms.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:105`
- **Verification:** View habit with 30 logs; see calculated optimal completion window displayed in analytics card.

---

### IMP-213: Goals Sheet Over-Allocation Warning Shield (>24 Hours/Day)
- **Category:** Reliability / Validation
- **Current behaviour:** In `GoalsSheet`, a user can set multiple daily goals totaling 28 hours in a single 24-hour day without receiving a warning.
- **Proposed improvement:** Calculate cumulative daily target allocation: if sum > 18 hours (leaving < 6 hours for sleep), display an amber warning badge: `"High Target Allocation: Total targets require 20h/day"`.
- **User benefit:** Protects ambitious users from setting impossible goals that lead to burnout and discouragement.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:310`
- **Verification:** Create three 8-hour daily goals; verify warning banner notes unrealistic daily hour demands.

---

### IMP-214: Project Reflection Dialog Key Takeaways Bullet List Parser
- **Category:** Functional / Productivity
- **Current behaviour:** In `ProjectReflectionDialog`, reflections are saved as plain unformatted text.
- **Proposed improvement:** Add structured prompt fields: (1) What went well? (2) What could be improved? (3) Key lessons learned, and format them into clean markdown bullets automatically.
- **User benefit:** High-value post-mortem project reviews formatted for executive retrospective files.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/project_reflection_dialog.dart:75`
- **Verification:** Complete project reflection; view saved note; verify structured markdown sections are created cleanly.

---

### IMP-215: Urge Surfing 60-Second Timer Extension Button ("+1 Minute")
- **Category:** User Flows / Mindfulness
- **Current behaviour:** In `lib/dialogs/urge_surfing_dialog.dart:63`, the box breathing session ends abruptly after exactly 60 seconds. Strong urges often last 2-3 minutes.
- **Proposed improvement:** Add a `"+1 Minute"` pill button during active breathing that extends the session without resetting breathing rhythm or phase index.
- **User benefit:** Users dealing with intense cravings can stay in the calm breathing zone as long as needed.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:70`
- **Verification:** Start urge surfing; tap '+1 Minute'; verify remaining seconds increase to 120 smoothly.

---

### IMP-216: Checkpoints Dashboard Habit Archive Instead of Delete
- **Category:** Reliability / Data Safety
- **Current behaviour:** Removing a habit checkpoint completely deletes the preset from `CheckpointService`, losing historical consistency records.
- **Proposed improvement:** Add an `isArchived: true` flag. Archived habits are hidden from the active dashboard but keep all past completion metrics and streaks intact.
- **User benefit:** Users can pause seasonal habits (e.g. Skiing, Summer Study) without destroying historical habit data.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/services/checkpoint_service.dart:180`
- **Verification:** Archive habit; confirm it disappears from quick bar while past logs remain safely searchable in History.

---

### IMP-217: Goals Sheet Archived Goals Filter Segmented Tab
- **Category:** UX / Organization
- **Current behaviour:** Completed or expired goals remain mixed in the primary goals list or must be permanently deleted.
- **Proposed improvement:** Add segmented pills at the top of `GoalsSheet`: `[Active (4)]` and `[Archived (12)]`.
- **User benefit:** Keeps active goal horizons focused while preserving a proud ledger of completed past achievements.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:120`
- **Verification:** Switch to Archived tab in Goals; view all completed targets from previous quarters.

---

### IMP-218: Sobriety Streak Card Savings Financial Calculator Widget
- **Category:** Motivation / Delight
- **Current behaviour:** `HomeSobrietyStreakCard` tracks days sober, but doesn't track money saved from quitting alcohol, cigarettes, or compulsive purchases.
- **Proposed improvement:** Add an optional `Daily Spend Saved` setting (e.g. `$15/day`). The card calculates and displays: `"$630 Saved over 42 days"`.
- **User benefit:** Powerful, tangible real-world motivator highlighting financial freedom gained from sobriety.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_sobriety_streak_card.dart:110`
- **Verification:** Set $20/day saved; check streak card at 30 days; verify "$600 Saved" badge displays proudly.

---

### IMP-219: Add/Edit Habit Target Time Picker 12h/24h System Synchronization
- **Category:** Consistency / Internationalization
- **Current behaviour:** In `lib/dialogs/add_edit_habit_sheet.dart:89`, `_targetMinuteOfDay` picker uses Cupertino wheels that can default to 24h format even when the user has 12h display configured globally.
- **Proposed improvement:** Read `use24HourFormat` setting and pass `use24hFormat: !p.is12h` into the time picker drum.
- **User benefit:** Consistent time picker format matching user preferences app-wide.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:92`
- **Verification:** Set app to 12-hour mode; open Add Habit; confirm time picker shows AM/PM drums cleanly.

---

### IMP-220: Checkpoints Dashboard Batch Reorder Drag Handles
- **Category:** Ergonomics / Personalization
- **Current behaviour:** Habit cards in `CheckpointsDashboardScreen` cannot be re-ordered.
- **Proposed improvement:** Add a "Reorder" action in the dashboard header that turns habit cards into a `ReorderableListView` with drag handles.
- **User benefit:** Align habits chronologically from morning wake-up to evening sleep routines.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:180`
- **Verification:** Drag 'Evening Reading' to bottom of dashboard list; confirm new order persists across app launches.

---

### IMP-221: Urge Surfing Emergency Sponsor / Hotline One-Tap Quick Call
- **Category:** Safety / Life Support
- **Current behaviour:** If an urge is severe and mindfulness breathing isn't enough, there is no direct link to call a support contact.
- **Proposed improvement:** Add a discreet "Call Support Sponsor" button in `UrgeSurfingDialog` that directly launches a pre-configured contact or national helpline via `tel:`.
- **User benefit:** Critical safety net during acute crisis moments for users dealing with serious addictions.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:180`
- **Verification:** Configure sponsor number; tap Call Sponsor during urge surfing; confirm phone dialer opens with contact prefilled.

---

### IMP-222: Project Milestone Progress Ring Mini-Complication
- **Category:** Visual Polish
- **Current behaviour:** In `ProjectsSheet:120`, project progress is shown as a linear bar with percentage text.
- **Proposed improvement:** Render a miniature 28dp circular progress ring with milestone tick marks representing individual completed deliverables.
- **User benefit:** High visual appeal and intuitive deliverable progress tracking matching Apple Fitness rings.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/projects_sheet.dart:135`
- **Verification:** View project with 3 of 5 milestones done; observe circular ring filled to 60% with 5 distinct milestone notches.

---

### IMP-223: Goals Sheet Pacing Color Alert (Green = Ahead, Red = Behind)
- **Category:** Visual Polish / UX
- **Current behaviour:** Goal progress bars always use `p.accent`, regardless of whether the user is on track to hit the goal or severely lagging behind.
- **Proposed improvement:** Color-code progress dynamically based on time elapsed in the period: `p.green` if pacing ≥ expected pace, `p.orange` if slightly behind (80-99%), `p.red` if lagging (<80%).
- **User benefit:** Instant visual heat map: glance at 5 goals and immediately know which ones require attention today.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:210`
- **Verification:** Compare on-track goal vs lagging goal; observe green vs amber progress bars.

---

### IMP-224: Checkpoint Session Sheet Note Prefill with Habit Emoji
- **Category:** Convenience / UX
- **Current behaviour:** In `CheckpointSessionSheet:78`, the note textfield is completely blank on appearance.
- **Proposed improvement:** Prefill the note with `#habit` and the habit's unique tag (e.g. `#running`, `#reading`) so the session is automatically indexed under that tag.
- **User benefit:** Automatic tag organization without manually typing hashtags for routine sessions.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:88`
- **Verification:** Open session sheet for 'Gym Workout'; confirm note field is pre-tagged with `#workout`.

---

### IMP-225: Sobriety Streak Shield Banking Visual Reward Animation
- **Category:** Delight / Gamification
- **Current behaviour:** When a user completes 7 clean days, a streak shield is added silently to `_streakShields` counter.
- **Proposed improvement:** Show a brief, glowing golden shield unlock animation: `"🛡️ Streak Shield Banked! You now have a 1-day safety net."`.
- **User benefit:** Strong psychological incentive celebrating weekly consistency and resilience.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/utils/streak_guardian_service.dart:110`
- **Verification:** Simulate 7th clean day; observe golden shield animation and congratulatory badge.

---

### IMP-226: Add/Edit Habit "Anytime" vs "Fixed Time" Segmented Control
- **Category:** User Flows / UX
- **Current behaviour:** In `lib/dialogs/add_edit_habit_sheet.dart:54`, toggling anytime vs fixed target time uses a small checkbox at the bottom of the form.
- **Proposed improvement:** Place a prominent Apple-style segmented pill at the top: `[Fixed Routine Time (e.g. 07:00 AM)]` vs `[Anytime During the Day]`.
- **User benefit:** Clear, intuitive mental model selection for time-specific habits vs flexible daily tasks.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:80`
- **Verification:** Switch between 'Fixed Time' and 'Anytime'; observe time picker drum slide in and out with smooth animation.

---

### IMP-227: Checkpoints Dashboard All Habits Completed Daily Crown
- **Category:** Delight / Visual Polish
- **Current behaviour:** When all habit checkpoints for the day are checked, the dashboard simply shows all cards with checkmarks.
- **Proposed improvement:** Display a glorious golden crown badge or laurel banner at the top of the screen: `"✨ All Daily Checkpoints Perfect! 100% Routine Mastery"`.
- **User benefit:** Huge psychological gratification for completing a flawless daily routine.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:140`
- **Verification:** Check off last remaining habit of the day; observe golden completion banner and celebratory haptic burst.

---

### IMP-228: Goals Sheet Target Period Selector Visual Icons (Day/Week/Month/Year)
- **Category:** Visual Polish
- **Current behaviour:** Selecting goal period in `GoalsSheet` uses a standard text dropdown.
- **Proposed improvement:** Use a clean 4-pill segmented selector with distinctive iconography: `[☀️ Day]`, `[📅 Week]`, `[🗓️ Month]`, `[🪐 Year]`.
- **User benefit:** Fast, tactile horizon selection with zero dropdown tapping overhead.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/goals_sheet.dart:160`
- **Verification:** Create new goal; select 'Month' via top segmented pill; verify horizon updates instantly.

---

### IMP-229: Urge Surfing Ambient Brown Noise / Rain Sound Option
- **Category:** Audio / Mindfulness
- **Current behaviour:** `UrgeSurfingDialog` operates in total silence unless audio chime is triggered.
- **Proposed improvement:** Add an optional ambient sound toggle playing soothing continuous looping Brown Noise or gentle mountain rain through `AudioService`.
- **User benefit:** Brown noise scientifically calms auditory cortex hyperactivity and quiets internal intrusive thoughts during cravings.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:120`
- **Verification:** Toggle Sound in urge surfing; hear calm, warm looping brown noise softly soothing in the background.

---

### IMP-230: Project Reflection Dialog Direct Export to Markdown Journal
- **Category:** Functional / Productivity
- **Current behaviour:** Project reflections are saved as a moment note in the Isar database only.
- **Proposed improvement:** Add an "Export Reflection" action that saves the reflection to the device's external Documents directory as `Project_Name_Reflection.md`.
- **User benefit:** Direct integration into Obsidian, Logseq, or external sovereign knowledge graphs.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/project_reflection_dialog.dart:95`
- **Verification:** Save project reflection; choose Export to Documents; verify cleanly formatted `.md` file in user storage.

---

### IMP-231: Checkpoints Dashboard Habit Streak Number Color Escalation
- **Category:** Visual Polish
- **Current behaviour:** In `CheckpointsDashboardScreen`, habit streaks are shown in standard text color.
- **Proposed improvement:** Escalate streak badge colors based on milestone longevity: 1-6 days = `p.text2`, 7-29 days = `p.green`, 30-99 days = `p.accent`, 100+ days = Radiant Gold `#FFD700` with flame emoji.
- **User benefit:** Visual prestige celebrating habits that have become true lifelong identities.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:275`
- **Verification:** View habit with 120-day streak; confirm glowing gold flame badge and distinct number styling.

---

### IMP-232: Goals Sheet Target Allocation vs Actual Hours Historical Bar Chart
- **Category:** Analytics / Visual Polish
- **Current behaviour:** `GoalsSheet` displays current active cycle progress, but cannot show past weekly performance for that specific goal.
- **Proposed improvement:** Add a compact 4-week historical sparkline bar chart comparing target hours vs actual completed hours for the past 4 cycles.
- **User benefit:** Long-term trend analysis: see whether consistency on this goal is rising or slipping.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:280`
- **Verification:** Open deep work goal; observe 4-week bar chart showing actual logged hours vs weekly 15-hour target.

---

### IMP-233: Checkpoint Session Sheet Start Time Drag Snapping to 5 Minutes
- **Category:** UX / Precision
- **Current behaviour:** Adjusting start and end points in `CheckpointSessionSheet` can produce awkward times like `08:43` to `09:13`.
- **Proposed improvement:** Automatically snap manual boundary drag adjustments to clean 5-minute multiples (`08:40`, `08:45`).
- **User benefit:** Clean, professional session logs matching standard corporate and calendar blocks.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:110`
- **Verification:** Adjust start slider in session sheet; observe values snap cleanly to 5-minute ticks.

---

### IMP-234: Sobriety Companion Milestone Quotes Philosophy Theming
- **Category:** Personalization / Inspiration
- **Current behaviour:** In `lib/models/sobriety_milestones.dart:50-80`, quotes use the default philosophy theme.
- **Proposed improvement:** Support 3 distinct quote themes selectable in settings: (1) Stoic Wisdom (Marcus Aurelius, Seneca), (2) Modern Neuroscience (Huberman, Clear), (3) Mindfulness Zen (Thich Nhat Hanh).
- **User benefit:** Tailors recovery motivation to the user's personal intellectual and spiritual framework.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/sobriety_companion_settings_page.dart:180`
- **Verification:** Select 'Stoic Wisdom' theme; view 30-day milestone; confirm Seneca quote appears on the milestone card.

---

### IMP-235: Add/Edit Habit Weekly Recurrence Schedule (e.g. Mon/Wed/Fri Only)
- **Category:** Functional Intelligence
- **Current behaviour:** Habits in `CheckpointService` are assumed to be daily. A 3-day workout routine breaks streak calculations on rest days.
- **Proposed improvement:** Add a 7-day recurrence selector (`M T W T F S S` toggle buttons). Rest days do not break streaks or penalize consistency scores.
- **User benefit:** Perfect support for gym splits, intermittent fasting, or workday-only routines.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/models/checkpoint.dart:45`
- **Verification:** Create MWF workout habit; verify Saturday and Sunday do not reset streak counter.

---

### IMP-236: Urge Surfing Post-Session Reflection Quick-Note
- **Category:** Recovery / UX
- **Current behaviour:** When an urge surfing session ends, the dialog closes back to home.
- **Proposed improvement:** Present a quick 1-tap reflection prompt: `"How do you feel now? [Calmer] [Urge Passed] [Still Struggling]"`, with an optional note field to log triggers.
- **User benefit:** Captures valuable recovery reflections right when emotional clarity returns.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:150`
- **Verification:** Complete 60s breathing; confirm quick reflection card appears with 1-tap state buttons.

---

### IMP-237: Projects Sheet Archive Project with Celebration Screen
- **Category:** Delight / Closure
- **Current behaviour:** Completing a project marks it done in the database without any visual fanfare.
- **Proposed improvement:** When the final milestone is checked and project is marked Completed, trigger a grand completion dialog with total hours invested, milestone timeline, and gold confetti.
- **User benefit:** Profound psychological closure for completing massive months-long initiatives.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/projects_sheet.dart:210`
- **Verification:** Complete last milestone of a project; observe celebratory completion summary sheet.

---

### IMP-238: Checkpoints Dashboard Zero-State Friendly Template Library
- **Category:** Onboarding / Discoverability
- **Current behaviour:** When a user has 0 habits, `CheckpointsDashboardScreen` shows an empty list with a "+" button.
- **Proposed improvement:** Provide 1-tap pre-baked habit packs: `[The Morning Monk Routine 🌅]`, `[Executive Deep Focus 💻]`, `[Physical Longevity 🏋️]`, adding 3 curated habits in 1 tap.
- **User benefit:** Instant high-value setup for new users without thinking up habits from scratch.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:160`
- **Verification:** Open empty checkpoints dashboard; tap 'Morning Monk Routine'; verify 3 habits populate automatically.

---

### IMP-239: Goals Sheet Multi-Category Goal Linking
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/models/goal.dart`, a goal is linked to exactly one category or all categories.
- **Proposed improvement:** Support multi-category tags: link a goal to both `Work` and `Writing`.
- **User benefit:** Cross-functional project tracking without artificially siloing work into single categories.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:340`
- **Verification:** Link goal to 'Work' and 'Research'; verify sessions logged in either category count toward the target.

---

### IMP-240: Checkpoints Quick Bar Haptic Feedback Distinction for Habits vs Sessions
- **Category:** Tactile Feedback
- **Current behaviour:** Checking off a habit in `CheckpointsQuickBar` uses `selectionClick()`, the same vibration used for standard button clicks.
- **Proposed improvement:** Use a distinct celebratory double-thump (`AppHaptics.success()`) specifically for habit completions.
- **User benefit:** Unique physical sensation in the hand that feels rewarding and distinct from generic navigation taps.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart:125`
- **Verification:** Check off habit in quick bar; feel the rich double-pulse success vibration.

---

### IMP-241: Sobriety Companion Relapse Trigger Analytics Frequency Chart
- **Category:** Analytics / Health
- **Current behaviour:** Trigger tags logged during resets can only be viewed by manually scrolling through history.
- **Proposed improvement:** Add a "Trigger Breakdown" pie/bar chart in Sobriety settings showing top relapse catalysts (e.g. 50% Fatigue, 30% Stress, 20% Social).
- **User benefit:** Critical psychological self-awareness helping users proactively guard against their specific vulnerabilities.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/sobriety_companion_settings_page.dart:220`
- **Verification:** View Sobriety settings; inspect Trigger Breakdown chart showing percentage breakdown of past reset tags.

---

### IMP-242: Add/Edit Habit Color Swatch Palette Match
- **Category:** Visual Polish
- **Current behaviour:** In `AddEditHabitSheet`, habit colors are randomly picked or default to blue.
- **Proposed improvement:** Provide a horizontal row of 12 circular color swatches directly derived from `p.accentColors` (`p.blue`, `p.green`, `p.orange`, `p.purple`, `p.red`, etc.).
- **User benefit:** Visual harmony across the app with zero clashing or off-brand color values.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:115`
- **Verification:** Open Add Habit; select 'Emerald' swatch; verify habit badge and checkmark glow match Emerald theme.

---

### IMP-243: Urge Surfing Box Breathing Inhale/Exhale Seconds Customizer (4-7-8 Rhythm)
- **Category:** Mindfulness / Flexibility
- **Current behaviour:** In `lib/dialogs/urge_surfing_dialog.dart:48`, the breathing rhythm is fixed at 4s Inhale, 4s Hold, 4s Exhale, 4s Hold (Box Breathing).
- **Proposed improvement:** Add a toggle for the renowned **4-7-8 Parasympathetic Relaxation Breathing** technique (4s Inhale, 7s Hold, 8s Exhale).
- **User benefit:** Deeper physiological calming for high-anxiety panic attacks and severe cravings.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:55`
- **Verification:** Select 4-7-8 mode; start breathing; observe breath timer track 4s -> 7s -> 8s phases accurately.

---

### IMP-244: Checkpoints Dashboard Time-to-Habit Countdown Pill
- **Category:** Functional Intelligence
- **Current behaviour:** For habits scheduled in the future today (e.g. Bedtime at 22:30), the card displays "22:30".
- **Proposed improvement:** Add a dynamic countdown pill: `"in 2 hours 15 mins"` that updates as the target routine window approaches.
- **User benefit:** Gentle temporal anchoring preparing the user's mind for their upcoming routine transitions.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:290`
- **Verification:** View evening habit at 19:00 scheduled for 22:00; confirm "in 3h" countdown pill displays cleanly.

---

### IMP-245: Projects Sheet Budgeted vs Actual Hours Variance Indicator
- **Category:** Productivity / Precision
- **Current behaviour:** Projects track accumulated hours, but don't compare them against an estimated total budget (e.g. 50-hour sprint).
- **Proposed improvement:** Add an optional "Estimated Total Budget Hours" field. When logging time, display: `"34 / 50h (68% budget utilized)"`.
- **User benefit:** Essential client project and sprint budget management for contractors and software engineers.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/projects_sheet.dart:160`
- **Verification:** Set project budget of 40h; log 20h; verify progress bar shows 50% budget utilized.

---

### IMP-246: Sobriety Companion Milestone Shield Grace Recovery Rules
- **Category:** Reliability / Architecture
- **Current behaviour:** If a user forgets to log clean for 24 hours, their streak breaks automatically unless a shield was pre-activated.
- **Proposed improvement:** Automatically consume a banked streak shield if an inadvertent midnight lapse occurs, preserving the streak with an alert: `"🛡️ Shield consumed to protect your 45-day streak"`.
- **User benefit:** Forgiving and realistic recovery companion that doesn't punish users for camping or having a dead phone battery.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/streak_guardian_service.dart:140`
- **Verification:** Bank 1 shield; simulate 24-hour absence past midnight; verify shield is consumed and streak remains intact.

---

### IMP-247: Goals Sheet Active Goal Indicator Badge on Home Clock Complication
- **Category:** Integration / Discoverability
- **Current behaviour:** When a goal is selected as active in `GoalsSheet`, returning to the home screen does not prominently display the active goal title under the clock unless the dynamic header is expanded.
- **Proposed improvement:** Display the active goal title with a target icon `🎯 Q4 Launch` directly in the home clock complication slot.
- **User benefit:** Constant, subtle environmental reminder of the user's single most critical focus goal.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/home_clock_complication.dart:65`
- **Verification:** Select 'Deep Work Goal'; return to home screen; observe target title cleanly integrated beneath clock digits.

---

### IMP-248: Checkpoint Session Sheet Note Voice Memo Attachment Direct Trigger
- **Category:** Convenience / Multimedia
- **Current behaviour:** `CheckpointSessionSheet` allows typing text notes, but lacks a microphone button to record a quick voice reflection for the habit session.
- **Proposed improvement:** Add a microphone icon button in the note bar that opens the voice recording pill directly within the habit session sheet.
- **User benefit:** Capture vocal workout thoughts or post-meditation realizations in 1 tap without typing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:130`
- **Verification:** Tap mic button in Checkpoint Session Sheet; record 10s voice memo; verify audio attaches to the habit moment.

---

### IMP-249: Add/Edit Habit Duplicate Habit Label Validation Guard
- **Category:** Validation / Data Integrity
- **Current behaviour:** Users can accidentally create two identical habits named "Morning Walk", resulting in duplicate cards and confusing statistics.
- **Proposed improvement:** Validate habit title against existing active presets; display an inline warning: `"A habit with this name already exists"`.
- **User benefit:** Prevents accidental duplicate habit entries and fragmented statistics.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:140`
- **Verification:** Attempt to save second habit named "Morning Walk"; confirm validation banner blocks duplicate creation.

---

### IMP-250: Urge Surfing Dark AMOLED Theme Optimization
- **Category:** Visual Polish / Accessibility
- **Current behaviour:** In `UrgeSurfingDialog`, background colors use dark grey `#1C1C1E`. In AMOLED theme, pixels remain illuminated.
- **Proposed improvement:** When `p.name == 'amoled'`, force dialog backdrop to pure `#000000`, creating a zero-light, soothing sensory-deprivation environment.
- **User benefit:** Total darkness at night reduces sensory stimulation and facilitates rapid urge de-escalation.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:85`
- **Verification:** Switch to AMOLED theme; open Urge Surfing; verify pure pitch-black background.

---

### IMP-251: Checkpoints Dashboard Weekly Consistency Percentage Badge
- **Category:** Functional Intelligence
- **Current behaviour:** The dashboard shows streaks, but does not display a cumulative weekly consistency percentage across all habits.
- **Proposed improvement:** Render an overall weekly consistency badge at the top: `"94% Weekly Habit Adherence"`.
- **User benefit:** Single macro-metric summarizing complete routine mastery across all daily habits.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:130`
- **Verification:** Complete 9 of 10 habits this week; observe accurate `90% Weekly Adherence` badge at top of dashboard.

---

### IMP-252: Projects Sheet Reorder Milestones via Drag and Drop
- **Category:** UX / Productivity
- **Current behaviour:** In `lib/dialogs/projects_sheet.dart:190`, project milestones are locked in the order they were typed.
- **Proposed improvement:** Add reorder handles to milestone checklist items, enabling users to reorder priorities as project realities shift.
- **User benefit:** Fluid agile milestone management without deleting and retyping items.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/projects_sheet.dart:200`
- **Verification:** Drag Milestone 3 to top position; confirm milestone order updates and saves to `ProjectService`.

---

### IMP-253: Goals Sheet Target Expiration Notice & Auto-Renewal Prompt
- **Category:** Reliability / UX
- **Current behaviour:** When a monthly goal period ends (e.g. on the 31st), it quietly stops tracking without notifying the user to set their next month's target.
- **Proposed improvement:** On cycle expiration, show a banner: `"October Goal Complete! Renew with same target for November? [Renew] [Adjust]"`.
- **User benefit:** Seamless continuity across calendar months without losing goal tracking momentum.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:360`
- **Verification:** Fast-forward mock date to 1st of month; open Goals; observe clear renewal prompt for expired monthly goals.

---

### IMP-254: Sobriety Streak Milestones Science Facts Integration
- **Category:** Education / Motivation
- **Current behaviour:** Science milestones display brief biological notes.
- **Proposed improvement:** Add in-depth medical explanations: at 72 hours (GABA receptor normalization), at 2 weeks (Dopamine baseline restoration), at 1 year (Prefrontal cortex gray matter regeneration).
- **User benefit:** Deep neurological and physiological understanding of the healing process taking place inside the user's brain.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/models/sobriety_milestones.dart:95`
- **Verification:** Inspect 2-week milestone card; read comprehensive neuroscience briefing on dopamine recovery.

---

### IMP-255: Add/Edit Habit Category Selector Color Badge Display
- **Category:** Visual Polish
- **Current behaviour:** Category selector in `AddEditHabitSheet` shows plain text category names.
- **Proposed improvement:** Prefix each category name with its vibrant squircle color badge (e.g. 🟦 Work, 🟩 Health, 🟪 Mind).
- **User benefit:** Instant visual alignment between habit categories and timeline session colors.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:125`
- **Verification:** Open category dropdown in Add Habit; verify colorful squircle chips beside each category title.

---

### IMP-256: Checkpoint Session Sheet Past Date Logging Capability
- **Category:** Functional / Convenience
- **Current behaviour:** `CheckpointSessionSheet` assumes the habit occurred today. If the user forgot to log yesterday's evening walk, they cannot backdate it inside this sheet.
- **Proposed improvement:** Add a "Change Date" link allowing users to select yesterday or up to 7 days in the past.
- **User benefit:** Easily backdate missed habit check-ins without having to navigate to manual entry.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:140`
- **Verification:** Tap 'Change Date' in Checkpoint Session Sheet; choose Yesterday; verify habit is credited to yesterday's date.

---

### IMP-257: Urge Surfing Breath Animation Smooth Scale Physics
- **Category:** Visual Polish / Mindfulness
- **Current behaviour:** In `lib/dialogs/urge_surfing_dialog.dart:48`, the expanding circle scales using linear animation, which feels mechanical.
- **Proposed improvement:** Use a natural lung expansion curve: `Curves.easeInOutSine` for inhale and `Curves.easeOutCubic` for exhale.
- **User benefit:** Organic, physiologically soothing visual breathing guide that feels natural to follow.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:52`
- **Verification:** Watch breathing circle expand and contract; observe gentle sine easing resembling human lung capacity expansion.

---

### IMP-258: Project Reflection Dialog Linked Moments Summary Table
- **Category:** Analytics / Reporting
- **Current behaviour:** `ProjectReflectionDialog` shows project notes, but doesn't list the sessions logged under that project.
- **Proposed improvement:** Render a compact scrollable list of all moments and sessions completed under this project with dates and duration subtotals.
- **User benefit:** Complete retrospective audit trail of all time invested into the project.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/project_reflection_dialog.dart:120`
- **Verification:** Open project reflection; view summary table showing every logged session and total cumulative hours.

---

### IMP-259: Goals Sheet Multi-Select Batch Goal Deletion
- **Category:** Convenience / UX
- **Current behaviour:** Deleting obsolete goals requires tapping each goal, opening edit, and deleting one by one.
- **Proposed improvement:** Add an "Edit / Clean Up" mode with circular checkboxes to batch delete or batch archive expired goals in 1 tap.
- **User benefit:** Rapid quarterly housekeeping of completed or abandoned targets.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/goals_sheet.dart:380`
- **Verification:** Select 3 expired goals in edit mode; tap Delete; confirm all 3 are pruned simultaneously.

---

### IMP-260: Checkpoints Quick Bar Dynamic Micro-Badges for Morning vs Evening
- **Category:** Functional Intelligence
- **Current behaviour:** All habits display in identical chips regardless of whether they are morning, afternoon, or evening routines.
- **Proposed improvement:** Display subtle contextual indicator dots: golden sun `☀️` for morning habits, amber twilight `🌆` for evening habits, fading habits outside current daytime focus.
- **User benefit:** Highlights the habits relevant to the current time of day first.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart:95`
- **Verification:** View quick bar in evening; observe evening habits highlighted with subtle amber glow.

---

### IMP-261: Sobriety Companion Milestone Widget Home Screen Mini-Card
- **Category:** Android System Integration / Motivation
- **Current behaviour:** Milestone achievements are only visible inside the app.
- **Proposed improvement:** Broadcast active milestone badge graphics to `SobrietyWidgetProvider.kt` for display on the Android home screen widget.
- **User benefit:** Inspiring reminder of personal strength every time the user unlocks their Android device.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/SobrietyWidgetProvider.kt:60`
- **Verification:** Reach 7-day milestone; inspect Android home widget; verify trophy icon and milestone level update on home screen.

---

### IMP-262: Add/Edit Habit Reminder Notification Option
- **Category:** Android System Integration / Notifications
- **Current behaviour:** Checkpoints rely on users opening the app to see their habits. There is no optional scheduled reminder notification.
- **Proposed improvement:** Add an optional toggle: `"Remind me at target time"` that schedules an Android exact alarm reminder via `ReminderReceiver.kt`.
- **User benefit:** Gentle, sovereign local notification ensuring habits are never forgotten during busy work days.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:160`
- **Verification:** Set reminder for 08:30 AM; receive clean, silent notification at 08:30 with 1-tap "Check Off" action.

---

### IMP-263: Goals Sheet Target Allocation Rollover Option
- **Category:** Functional Intelligence
- **Current behaviour:** Unused deficit hours from last week do not roll over; each week resets to 0.
- **Proposed improvement:** Add an optional setting: `Rollover Deficit/Surplus Hours to Next Week`.
- **User benefit:** Accurate long-term pacing for complex academic dissertations or freelance contracts.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/goals_sheet.dart:395`
- **Verification:** Fall 2 hours short of weekly goal; start new week; observe 2-hour deficit added to initial target.

---

### IMP-264: Urge Surfing Emergency Breathing Card Screen-On Guard
- **Category:** Reliability / Mindfulness
- **Current behaviour:** During urge surfing, if the user does not touch the screen, the display can sleep after 30 seconds, interrupting the breathing guide.
- **Proposed improvement:** Acquire a temporary wake-lock (`WakelockPlus.enable()`) for the duration of the urge surfing session, releasing it automatically upon exit.
- **User benefit:** Guaranteed uninterrupted mindfulness breathing without having to tap the screen to keep it awake.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:60`
- **Verification:** Start urge surfing; don't touch screen for 90 seconds; verify screen remains comfortably illuminated throughout.

---

### IMP-265: Checkpoints Dashboard Habit Notes Frequency Word Cloud
- **Category:** Analytics / Insights
- **Current behaviour:** Notes attached to habit checkpoints can only be viewed one by one.
- **Proposed improvement:** Generate a compact keyword chip cloud from notes logged under that habit over the last 90 days (e.g. for Workout: `Legs 12x`, `Cardio 8x`, `Felt Strong 15x`).
- **User benefit:** High-level qualitative trends summarizing qualitative notes attached to daily habits.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:310`
- **Verification:** View habit analytics; observe top recurring note tags displayed in clean chip cloud.

---

### IMP-266: Projects Sheet Milestone Due Date Reminder
- **Category:** Functional / Planning
- **Current behaviour:** Milestones inside projects have titles, but cannot have individual target completion dates.
- **Proposed improvement:** Add an optional Due Date picker to individual milestones with a visual countdown badge (`Due in 4 days`).
- **User benefit:** Realistic intermediate project planning that prevents last-minute deadline rushes.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/projects_sheet.dart:225`
- **Verification:** Set due date on milestone; observe clean date badge and overdue warning if date passes.

---

### IMP-267: Sobriety Companion Relapse Cost Impact Lifetime Total
- **Category:** Analytics / Motivation
- **Current behaviour:** If a user logs multiple resets over a year, past money saved calculations only show current active streak.
- **Proposed improvement:** Track and display cumulative lifetime statistics: `"Total Days Sober This Year: 312 of 365 (85% Success Rate) • $4,680 Total Saved"`.
- **User benefit:** Reinforces that past sober days still count toward overall health transformation, eliminating the "what the hell" effect.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/settings/sobriety_companion_settings_page.dart:240`
- **Verification:** View Sobriety stats with past resets; observe proud cumulative lifetime clean ratio and total money saved.

---

### IMP-268: Checkpoint Session Sheet Start Live Handoff Animation
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** Tapping "Start Live" in `CheckpointSessionSheet` closes the sheet instantly and starts timing on the home screen.
- **Proposed improvement:** Animate the sheet smoothly sliding down while the home clock face expands with a green pulse and hero tag transition.
- **User benefit:** Fluid visual continuity connecting the habit sheet directly to the live home stopwatch.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:160`
- **Verification:** Tap 'Start Live' in habit sheet; watch smooth spatial morph into the home chronometer.

---

### IMP-269: Add/Edit Habit Custom Sound Effect Assignment
- **Category:** Audio / Personalization
- **Current behaviour:** Completing any habit plays the standard click sound.
- **Proposed improvement:** Allow assigning custom completion sounds per habit preset: (e.g. Zen Bell for Meditation, Athletic Whistle for Workout, Soft Water Drop for Hydration).
- **User benefit:** Distinct acoustic rewards tailored to different behavioral habit identities.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:180`
- **Verification:** Check off Hydration habit; hear gentle water drop acoustic chime.

---

### IMP-270: Goals Sheet Daily Horizon Time-Allocation Visual Ring
- **Category:** Visual Polish / Analytics
- **Current behaviour:** Goals display separate linear bars.
- **Proposed improvement:** Render a consolidated multi-ring or concentric ring chart at the top of `GoalsSheet` showing total daily allocated time vs remaining 24-hour horizon.
- **User benefit:** High-level macro perspective on how the 24 hours of today are intentionally budgeted.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:140`
- **Verification:** Open Goals Sheet; observe concentric ring visual showing intentional hours budgeted vs free time.

---

### IMP-271: Urge Surfing Guided Audio Voiceover Option
- **Category:** Accessibility / Mindfulness
- **Current behaviour:** Urge surfing is visual-only with text prompts.
- **Proposed improvement:** Add an optional calm, soothing voice guidance audio track: `"Breathe in deeply through your nose... and hold... gently exhale..."`.
- **User benefit:** Complete hands-free, eyes-closed guidance for users experiencing severe distress or panic.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:135`
- **Verification:** Toggle Voice Guidance in Urge Surfing; close eyes; listen to calm pacing cues guide the breath.

---

### IMP-272: Projects Sheet Active Project Quick Switch from Home Screen
- **Category:** User Flows / Shortcuts
- **Current behaviour:** To switch which project is active, users must open Projects Sheet, select project, and close sheet.
- **Proposed improvement:** Long-pressing the category pill bar on the home screen displays a quick popup menu to switch the active project in 1 tap.
- **User benefit:** Rapid context switching between client projects in under 1 second.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/note_kar_home.dart:880`
- **Verification:** Long-press category pill on home; tap 'Project Beta'; verify home session attaches to Project Beta instantly.

---

### IMP-273: Checkpoints Dashboard Minimum Streak Shield Threshold Setting
- **Category:** Settings / Flexibility
- **Current behaviour:** Streak shields are fixed at 1 shield every 7 days.
- **Proposed improvement:** Allow users to calibrate shield earning cadence: `1 shield every 5 days | 7 days | 14 days`.
- **User benefit:** Adaptable discipline rules matching user recovery stage and rigor.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/settings/sobriety_companion_settings_page.dart:260`
- **Verification:** Change shield earning to 5 days; verify shield banks upon completing 5 clean days.

---

### IMP-274: Add/Edit Habit "Target Duration" Field for Session Habits
- **Category:** Functional Intelligence
- **Current behaviour:** Habits only record timestamps. A "Gym Workout" habit doesn't have an expected duration target.
- **Proposed improvement:** Add an optional "Target Session Duration" field (e.g. 45 mins). When logging via session, prefill the session duration with 45 minutes automatically.
- **User benefit:** 1-tap logging pre-configured to the user's expected workout or meditation duration.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:195`
- **Verification:** Set 30m target duration on 'Reading'; tap habit on home; verify 30-minute session is pre-filled.

---

### IMP-275: Sobriety Companion Relapse Trigger Pattern Correlation Warning
- **Category:** Functional Intelligence / Predictive AI
- **Current behaviour:** If a user relapses repeatedly on Friday nights, no proactive warning is given.
- **Proposed improvement:** Analyze temporal relapse clustering: if 3 past resets occurred on Friday after 21:00, display a proactive Friday afternoon shield card: `"Vulnerability Window: Friday evenings are historically challenging. Plan a quiet activity or reach out to support."`.
- **User benefit:** Life-saving proactive awareness before entering high-risk behavioral danger zones.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/streak_guardian_service.dart:180`
- **Verification:** Log past resets clustered on Fridays; open app on Friday afternoon; observe empathetic proactive shield alert.

---

### IMP-276: Checkpoint Session Sheet Visual Timeline Duration Drag Handle
- **Category:** Visual Polish / UX
- **Current behaviour:** In `CheckpointSessionSheet`, adjusting duration uses +/- buttons and quick chips.
- **Proposed improvement:** Render a sleek horizontal slider bar with elastic Apple-style drag handle showing live start, end, and duration updating interactively.
- **User benefit:** Visually engaging and tactile boundary adjustment.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:175`
- **Verification:** Drag slider handle; observe start time and duration numbers smoothly glide in real time.

---

### IMP-277: Goals Sheet Automatic Goal Archiving Upon Expiration Option
- **Category:** Settings / Housekeeping
- **Current behaviour:** Expired goals remain in active view indefinitely until manually archived.
- **Proposed improvement:** Add a toggle `Auto-Archive Goals After Period Ends` that automatically moves completed past weekly/monthly goals to the Archived tab.
- **User benefit:** Always keeps the active Goals sheet pristine and relevant.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/goals_sheet.dart:410`
- **Verification:** Enable auto-archive; let weekly goal reach Monday 00:00; verify goal cleanly transitions to Archived tab.

---

### IMP-278: Urge Surfing Guided Progressive Muscle Relaxation Step
- **Category:** Mindfulness / Body Awareness
- **Current behaviour:** Grounding mode uses 5-4-3-2-1 sensory prompts only.
- **Proposed improvement:** Add a 3rd Urge Mode: `Progressive Muscle Relaxation` guiding users through tensing and releasing shoulders, hands, jaw, and stomach.
- **User benefit:** Physically dissipates trapped somatic adrenaline and nervous tension during acute panic or cravings.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:45`
- **Verification:** Select Muscle Relaxation mode; follow guided prompts to release physical shoulder and jaw tension.

---

### IMP-279: Projects Sheet Deliverables Progress Percent Badge
- **Category:** Typography / Polish
- **Current behaviour:** In `ProjectsSheet`, percentage text uses standard proportional numbers.
- **Proposed improvement:** Apply `fontFeatures: [FontFeature.tabularFigures()]` with a bold 13pt badge style.
- **User benefit:** Clean tabular figure alignment across all project progress percentages.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P3
- **Implementation location:** `lib/dialogs/projects_sheet.dart:170`
- **Verification:** Inspect project progress percentage; confirm monospaced figure alignment.

---

### IMP-280: Checkpoints Dashboard Habit Calendar View
- **Category:** Analytics / Calendar
- **Current behaviour:** The dashboard shows a 7-day matrix only. Users cannot view their full 30-day or 90-day consistency calendar for a specific habit.
- **Proposed improvement:** Tapping a habit card opens a dedicated full-month mini-calendar showing green check dots for every day of the month the habit was completed.
- **User benefit:** High-satisfaction visual habit tracking inspired by the "Don't Break the Chain" Jerry Seinfeld method.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:330`
- **Verification:** Tap 'Morning Workout' card; view 30-day calendar grid filled with green completion checkmarks.

---

### IMP-281: Sobriety Companion Milestone Celebration Particle Color Theming
- **Category:** Visual Polish
- **Current behaviour:** In `MilestoneCelebrationDialog`, confetti particles always use generic primary colors.
- **Proposed improvement:** Tint confetti particles to match the user's active app accent color and milestone prestige tier (Gold, Emerald, Diamond).
- **User benefit:** Harmonious, visually stunning celebratory moments that match user aesthetics.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/milestone_celebration_dialog.dart:40`
- **Verification:** Celebrate milestone in Purple theme; observe confetti particles shimmer in violet, lilac, and gold.

---

### IMP-282: Add/Edit Habit Quick Icon Search Bar
- **Category:** UX / Convenience
- **Current behaviour:** Selecting an emoji or icon requires browsing through a list of popular emojis.
- **Proposed improvement:** Add a quick search bar to search across all standard emojis and Material/Cupertino habit icons.
- **User benefit:** Find obscure icons (e.g. `Violin`, `Chess`, `Stretching`, `Vitamins`) in 2 seconds.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:105`
- **Verification:** Type "chess" in habit icon search; verify ♟️ appears for instant selection.

---

### IMP-283: Goals Sheet Target Allocation Surplus Celebration Badge
- **Category:** Delight / Motivation
- **Current behaviour:** When a goal reaches 100%, the bar fills to maximum and stays static.
- **Proposed improvement:** When a goal exceeds 100% (e.g. 120%), display a glowing purple badge: `"+3.5h Surplus! Goal Exceeded ★"`.
- **User benefit:** Celebrates extraordinary dedication when users push past their initial expectations.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/goals_sheet.dart:230`
- **Verification:** Log 12 hours on a 10-hour goal; observe glowing Surplus badge and golden star icon.

---

### IMP-284: Checkpoint Session Sheet Direct Camera Photo Proof Attachment
- **Category:** Accountability / Multimedia
- **Current behaviour:** Taking a photo proof for a habit (e.g. photo of completed running shoes or finished book chapter) requires logging through the home note dialog.
- **Proposed improvement:** Add a camera shutter button directly in `CheckpointSessionSheet` to snap and attach photo proof in 1 tap.
- **User benefit:** Visual habit proof and tangible photographic memories of daily achievements.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:190`
- **Verification:** Tap camera in habit session sheet; snap photo; verify photo attaches to habit record.

---

### IMP-285: Sobriety Companion In-App Milestone Badge Showcase Gallery
- **Category:** Delight / Gamification
- **Current behaviour:** Past milestone celebrations disappear once dismissed. Users cannot look back at all the milestone badges they have unlocked over time.
- **Proposed improvement:** Add a "Trophy Case" gallery in Sobriety settings displaying all earned sovereign milestone badges with unlock dates.
- **User benefit:** Enduring visual trophy cabinet reinforcing pride in hard-earned sobriety.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/settings/sobriety_companion_settings_page.dart:280`
- **Verification:** Open Trophy Case in Sobriety settings; view beautifully illuminated badges for 24h, 7d, 30d, and 90d.

---

### IMP-286: Urge Surfing Session Audio Haptic Synchronization
- **Category:** Tactile Feedback / Mindfulness
- **Current behaviour:** Haptic pulses and breathing circle animations run on independent timers, which can drift by 100ms over a 60-second session.
- **Proposed improvement:** Drive haptic triggers directly from the `AnimationController.addStatusListener` and normalized value transitions.
- **User benefit:** Perfect, seamless hardware synchronization between visual circle expansion and tactile finger pulses.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:55`
- **Verification:** Hold phone during box breathing; feel vibration fire at the exact millisecond circle reaches peak expansion.

---

### IMP-287: Projects Sheet Quick Archive Filter Toggle
- **Category:** Organization / Polish
- **Current behaviour:** Projects sheet uses a tab bar to switch between Active and Completed.
- **Proposed improvement:** Support smooth swipe gestures between Active and Completed tabs with badge counts (`Active (3)` | `Done (14)`).
- **User benefit:** Fast, fluid navigation through project portfolios.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/projects_sheet.dart:70`
- **Verification:** Swipe horizontally between Active and Done tabs; observe smooth tab transition.

---

### IMP-288: Checkpoints Dashboard Habit Completion Sound Toggle
- **Category:** Settings / Accessibility
- **Current behaviour:** Checking off a habit always triggers audio click if sound effects are on globally.
- **Proposed improvement:** Add an independent toggle in Checkpoints settings: `Acoustic Sound on Habit Completion`.
- **User benefit:** Granular audio control for users who prefer silent habit checking in quiet office spaces.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:195`
- **Verification:** Turn off habit completion sounds; check off habit; verify haptic click remains while audio stays silent.

---

### IMP-289: Goals Sheet Dynamic Period End Date Label
- **Category:** Clarity / Visual Polish
- **Current behaviour:** Goals display `"Weekly Target"`. Users don't know whether the week ends on Sunday midnight or 7 days from creation.
- **Proposed improvement:** Explicitly display the cycle end date: `"Week ends Sunday, Nov 8 at 23:59"`.
- **User benefit:** Unambiguous deadline clarity for planning daily study or work allocations.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:175`
- **Verification:** View weekly goal; confirm exact Sunday cycle reset date and time are clearly stated.

---

### IMP-290: Add/Edit Habit Preset Description Helper Text
- **Category:** Guidance / Onboarding
- **Current behaviour:** In `AddEditHabitSheet`, the form fields have no helper tips explaining how target minutes work.
- **Proposed improvement:** Add subtle 12pt caption footer: `"Target Time: The ideal time of day you intend to start this habit. NoteKar will track timing variance around this point."`.
- **User benefit:** Clear educational guidance ensuring users configure their habit clocks correctly.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:150`
- **Verification:** Inspect Add Habit form footer; read clear descriptive explanation of timing variance.

---

### IMP-291: Sobriety Companion Sovereign Reset Journal Encryption Tagging
- **Category:** Privacy / Security
- **Current behaviour:** When a relapse note is logged, it is stored in standard moment storage.
- **Proposed improvement:** Automatically flag relapse reflections with an encrypted sensitivity tag, requiring biometric confirmation to view if App Lock is active.
- **User benefit:** Sovereign privacy protection for sensitive personal struggles and vulnerability notes.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/note_dialog.dart:670`
- **Verification:** Enable App Lock; view timeline containing relapse note; confirm biometric unlock is requested before note text reveals.

---

### IMP-292: Checkpoint Session Sheet Duration Slider Haptic Detents
- **Category:** Tactile Feedback
- **Current behaviour:** Dragging the duration slider in `CheckpointSessionSheet` is smooth but provides no haptic clicks.
- **Proposed improvement:** Fire a delicate `selectionClick()` on every 15-minute slider boundary (15m, 30m, 45m, 60m).
- **User benefit:** Precise physical slider feel allowing users to dial in duration without watching the numbers closely.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/checkpoint_session_sheet.dart:180`
- **Verification:** Drag duration slider; feel distinct haptic notches at 15m, 30m, 45m, 60m.

---

### IMP-293: Projects Sheet Milestone Completion Timestamp Preservation
- **Category:** Data Integrity / Reporting
- **Current behaviour:** Checking a milestone sets `isCompleted: true`, but discards the exact time of completion.
- **Proposed improvement:** Store `completedAt: DateTime.now().millisecondsSinceEpoch` on milestone records.
- **User benefit:** Accurate audit history of exact project velocity and deliverable milestones over time.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/models/project.dart:35`
- **Verification:** Complete milestone; check project details; verify exact date and time of completion are preserved.

---

### IMP-294: Goals Sheet Quick Target Duplication into New Cycle
- **Category:** Convenience / UX
- **Current behaviour:** When a project or goal cycle finishes, creating the same goal for next month requires re-entering title, category, and target hours.
- **Proposed improvement:** Add a "Duplicate Goal" action in the goal card menu that clones all configurations into the new active cycle in 1 tap.
- **User benefit:** 1-tap monthly goal renewal saving repetitive setup effort.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/goals_sheet.dart:420`
- **Verification:** Tap 'Duplicate Goal' on 'Reading Goal'; verify identical goal is cloned for next period.

---

### IMP-295: Urge Surfing Audio Fade-Out on Premature Dismissal
- **Category:** Audio / Polish
- **Current behaviour:** If a user closes `UrgeSurfingDialog` while ambient sound or music is playing, the audio cuts out abruptly with a pop.
- **Proposed improvement:** Fade out audio volume smoothly over 300ms using a volume ramp before stopping the player.
- **User benefit:** Gentle, polite acoustic fade out that avoids harsh clicks.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart:160`
- **Verification:** Dismiss urge surfing while sound is playing; verify audio fades out gently over 300ms.

---

### IMP-296: Checkpoints Dashboard Streak Recovery Grace Window Display
- **Category:** Clarity / UX
- **Current behaviour:** If a habit was missed yesterday, the user doesn't know whether they have until midday today to log it before the streak resets.
- **Proposed improvement:** If a grace period is active, display a subtle warning pill: `"Grace Window Active: Log yesterday's habit by 12:00 PM to save your 34-day streak"`.
- **User benefit:** Transparent streak guardian rules that prevent accidental streak loss.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:350`
- **Verification:** Miss habit yesterday; open dashboard this morning; observe clear grace window countdown banner.

---

### IMP-297: Add/Edit Habit Target Time "Now" Shortcut Button
- **Category:** Convenience / UX
- **Current behaviour:** In `AddEditHabitSheet`, setting the target routine time to the current time requires spinning the time wheels.
- **Proposed improvement:** Add a `"Use Current Time"` pill button beside the time picker drum that sets `_targetMinuteOfDay` to `now.hour * 60 + now.minute` in 1 tap.
- **User benefit:** Instant habit time setup matching the user's current live routine.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/add_edit_habit_sheet.dart:165`
- **Verification:** Tap 'Use Current Time' in Add Habit; confirm time drums snap to current clock time.

---

### IMP-298: Sobriety Companion Milestone Share Card QR Verification Code
- **Category:** Privacy / Verification
- **Current behaviour:** Milestone share cards have no cryptographic hash proving their sovereign validity.
- **Proposed improvement:** Include a subtle cryptographic hash verification badge in the corner of the milestone export card (`SHA256: e8b4...`).
- **User benefit:** Mathematical authenticity for sobriety accountability networks and personal validation.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/dialogs/shareable_milestone_sheet.dart:85`
- **Verification:** Export milestone card; verify clean cryptographic hash badge in bottom corner.

---

### IMP-299: Projects Sheet Deliverable Milestone Dependency Blocking
- **Category:** Productivity / Logic
- **Current behaviour:** All milestones in a project can be checked off in any random order, even if Milestone 2 depends on Milestone 1.
- **Proposed improvement:** Add an optional `Sequential Ordering` toggle: Milestone 2 remains locked/disabled until Milestone 1 is completed.
- **User benefit:** Enforces true disciplined sequential project execution.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/projects_sheet.dart:240`
- **Verification:** Enable sequential milestones; try to check Milestone 2; verify prompt requires completing Milestone 1 first.

---

### IMP-300: Checkpoints Dashboard Pull-to-Calculate Real-Time Stats
- **Category:** Performance / Reliability
- **Current behaviour:** In `CheckpointsDashboardScreen:80-95`, stats are calculated once during `build()`.
- **Proposed improvement:** Memoize stats calculations in a `ValueNotifier` and only recalculate when moments stream emits a mutation event.
- **User benefit:** Eliminates redundant standard deviation calculations on every micro-rebuild or scroll frame.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/checkpoints_dashboard_screen.dart:85`
- **Verification:** Profile CPU usage while scrolling habit cards; observe 60% reduction in mathematical compute cycles.
