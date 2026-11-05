# NoteKar 500+ Micro-Improvements Inventory: Part 4
## Focus Area: History Dialog, Calendar Day View, Analytics, Search Engine, Filter Sheets & Executive Intelligence Hub
### Items: IMP-301 to IMP-400

---

### IMP-301: History Day-Swipe Velocity-Aware Spring Physics
- **Category:** Gestures / Micro-Interaction
- **Current behaviour:** In `lib/widgets/history_calendar_view.dart:88-120`, swiping horizontally between days uses default `PageController` physics. Gentle flings occasionally fail to cross the 50% threshold and snap back, forcing users to re-swipe deliberately.
- **Proposed improvement:** Implement custom `BouncingScrollPhysics` with a lower velocity threshold (`velocity > 250dp/s`) to trigger page snap, matching Apple Calendar day-paging ergonomics.
- **User benefit:** Effortless, light flicking between chronological days without gesture failure.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/history_calendar_view.dart:95`
- **Verification:** Flick thumb lightly left on day timeline; verify day advances snappily to the next date.

---

### IMP-302: Day Detail Sheet Hour Activity Heatmap Color Ramp Accuracy
- **Category:** Visual Polish / Analytics
- **Current behaviour:** In `lib/dialogs/day_detail_sheet.dart:95-115`, the 24-hour activity bar uses arbitrary opacity scaling that saturates at 3 events per hour, making 10 events look visually identical to 3.
- **Proposed improvement:** Calculate true normalized hourly density: `alpha = (hourActivity[h] / maxEventsInSingleHour).clamp(0.15, 1.0)`.
- **User benefit:** Accurate visual representation of peak productivity hours across the 24-hour diurnal cycle.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:102`
- **Verification:** View Day Detail with 8 events at 14:00 and 2 at 10:00; confirm distinct, graduated visual intensity between bars.

---

### IMP-303: Daily Wrap-Up Unsaved Reflection Persistence on Backgrounding
- **Category:** Reliability / Data Safety
- **Current behaviour:** In `lib/dialogs/daily_wrapup_sheet.dart:98-120`, if a user types a thoughtful daily reflection into `_noteCtrl` and switches apps to look up a date, Android can clear memory, erasing the uncommitted reflection draft.
- **Proposed improvement:** Auto-save draft text to `SharedPreferences.setString('draft.daily_wrapup', text)` on every text change; restore it during `initState()`.
- **User benefit:** Zero risk of losing evening reflections or personal daily journal entries.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:105`
- **Verification:** Type reflection; minimize app; simulate process death; reopen Daily Wrap-Up; confirm draft text restores seamlessly.

---

### IMP-304: Executive Intelligence Hub Timeframe Pill Animation Rebound
- **Category:** Visual Polish
- **Current behaviour:** In `lib/screens/executive_intelligence_hub_screen.dart:95-102`, switching between `Week`, `Month`, `Quarter`, and `Year` uses standard state replacement without an animated sliding indicator pill.
- **Proposed improvement:** Implement an animated sliding background pill container with `NkCurves.appleEase` and 220ms transition.
- **User benefit:** Sleek tactile movement matching iOS Settings and Health analytics.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:98`
- **Verification:** Tap 'Month' then 'Year'; watch active pill glide smoothly across the segmented track.

---

### IMP-305: Smart Search Instant Prefix Matching (`cat:`, `tag:`, `min:`)
- **Category:** Search Intelligence / Power Users
- **Current behaviour:** In `lib/dialogs/search_dialogs.dart:95-130`, search queries perform basic substring checks on note text. Users cannot search for specific durations or categories via text syntax.
- **Proposed improvement:** Support smart search operators: `cat:work`, `tag:deepwork`, `min:>60m`, `before:2026-10-01` inside `SmartSearchFilter`.
- **User benefit:** Lightning-fast precision queries for research archives and tax/billing audits.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/services/smart_search_filter.dart:65`
- **Verification:** Type `cat:work min:>2h` into search bar; verify only work sessions longer than 2 hours are returned.

---

### IMP-306: History Calendar View Top Date Strip Haptic Detent
- **Category:** Tactile Feedback
- **Current behaviour:** In `lib/widgets/history_calendar_view.dart:90-95`, scrolling the horizontal date strip provides no haptic feedback when days cross the center point.
- **Proposed improvement:** Fire `HapticFeedback.selectionClick()` whenever a new date snaps into the center viewport of `_stripScrollController`.
- **User benefit:** Physical tactile sensation of thumbing through a physical paper calendar index.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/history_calendar_view.dart:92`
- **Verification:** Drag date strip horizontally; feel soft rhythmic clicks as dates pass the center indicator.

---

### IMP-307: Day Detail Sheet "Share Day Summary" Formatted Card Export
- **Category:** Delight / Export
- **Current behaviour:** `DayDetailSheet` allows inspecting the day, but lacks an export action.
- **Proposed improvement:** Add a "Share Day" button generating a sleek 1080x1920 image or Markdown summary: total hours, category breakdown, completed habits, and highlighted notes.
- **User benefit:** Share daily triumphs with mentors, accountability partners, or social journals.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:180`
- **Verification:** Tap Share in Day Detail; view high-res visual card with day's total hours and category rings.

---

### IMP-308: Search Notes Highlighted Keyword Background Color Tint
- **Category:** Visual Polish / Accessibility
- **Current behaviour:** In `lib/dialogs/search_dialogs.dart:140-160`, matching search keywords are highlighted with bold text only. Long paragraphs make it difficult to spot where the match occurred.
- **Proposed improvement:** Wrap matching tokens in a subtle glowing background badge (`p.accent.withValues(alpha: 0.2)`) with 2dp horizontal padding and rounded corners.
- **User benefit:** Eyes instantly land on the exact matched query inside dense note bodies.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/search_dialogs.dart:145`
- **Verification:** Search for "contract"; view results; verify "contract" is highlighted with a clear accent background glow.

---

### IMP-309: Executive Intelligence Hub 90-Day Heatmap Micro-Cell Touch Tooltip
- **Category:** User Flows / UX
- **Current behaviour:** In `lib/widgets/activity_heatmap_widget.dart:45-80`, tapping a 12x12dp heatmap square shows a toast message, but lacks precise alignment above the tapped cell.
- **Proposed improvement:** Render a floating Apple-style callout bubble directly above the tapped cell: `"Tue, Oct 14 • 6.4h tracked (9 moments)"`.
- **User benefit:** Flawless inspection of daily consistency history on GitHub-style activity heatmaps.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/activity_heatmap_widget.dart:65`
- **Verification:** Tap any square in the 90-day activity grid; observe clear floating tooltip hovering right over that day.

---

### IMP-310: Timeline Filter Sheet "Clear All Filters" Micro-Reset Button
- **Category:** User Flows / UX
- **Current behaviour:** In `lib/dialogs/timeline_filter_sheet.dart:40-60`, resetting an active filter requires deselecting each category, hashtag, and mode individually.
- **Proposed improvement:** Add a prominent "Reset All" button in the filter sheet header when `criteria.isActive` is true.
- **User benefit:** 1-tap reset back to the unfiltered full timeline view.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/timeline_filter_sheet.dart:55`
- **Verification:** Apply category and hashtag filters; open filter sheet; tap 'Reset All'; verify full timeline restores instantly.

---

### IMP-311: History Multi-Select Batch Deletion Confirmation Shield
- **Category:** Reliability / Data Safety
- **Current behaviour:** In `lib/dialogs/history_dialog.dart:158`, selecting multiple moments and tapping Delete asks for confirmation, but does not preview the list of dates or categories being deleted.
- **Proposed improvement:** Show an explicit audit sheet: `"Delete 8 Moments? (Includes 3 Work sessions, 2 Voice notes) [Cancel] [Move to Trash]"`.
- **User benefit:** Complete transparency preventing accidental deletion of irreplaceable audio or work logs.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/history_dialog.dart:165`
- **Verification:** Multi-select 5 moments; tap delete; verify detailed itemized breakdown in confirmation dialog.

---

### IMP-312: Daily Wrap-Up Active Session Direct Finalization
- **Category:** User Flows / Convenience
- **Current behaviour:** In `DailyWrapupPage`, if a session is still running at night, the user cannot easily set its exact ending time within the wrap-up flow without navigating back to home.
- **Proposed improvement:** Add an inline "End & Seal Active Session" card directly inside the wrap-up flow with an end-time adjuster.
- **User benefit:** Complete the entire evening shutdown and time audit without hopping between screens.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:130`
- **Verification:** Open Daily Wrap-Up with live session running; tap 'End & Seal'; verify session ends cleanly inside wrap-up.

---

### IMP-313: Executive Hub Memento Mori Mortality Horizon Age Customization
- **Category:** Personalization / Mindfulness
- **Current behaviour:** The Memento Mori life horizon calculation uses a hardcoded life expectancy of 80 years.
- **Proposed improvement:** Allow users to calibrate their target horizon age (e.g. 75, 85, 90) or toggle between Remaining Years, Remaining Weeks, or Remaining Days.
- **User benefit:** Profoundly personal and respectful mortality contemplation tailored to family history and philosophy.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:180`
- **Verification:** Change target horizon to 85 years in profile; inspect Memento Mori grid; verify week calculations update accordingly.

---

### IMP-314: Search Dialogs Recent Search History Carousel
- **Category:** Convenience / UX
- **Current behaviour:** In `NoteSearchDialog`, opening search shows a blank field. Users frequently search for the same project or client tag.
- **Proposed improvement:** Store last 5 search queries in `SharedPreferences` and display them as 1-tap horizontal search chips beneath the search bar.
- **User benefit:** Repeat common searches in 0.2 seconds without typing.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/search_dialogs.dart:110`
- **Verification:** Search for "Acme Corp"; close and reopen search; verify "Acme Corp" chip appears for 1-tap execution.

---

### IMP-315: History Calendar View Circular Day Clock Diagram
- **Category:** Visual Polish / Innovation
- **Current behaviour:** In `HistoryCalendarView`, days are represented as linear vertical lists.
- **Proposed improvement:** Add an optional 24-hour circular horology dial view where hours of the day form a 360° ring with colored session arcs showing morning, afternoon, and night distributions.
- **User benefit:** Breathtaking visual representation of the circadian day inspired by high-end horology complications.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/history_calendar_view.dart:210`
- **Verification:** Toggle Circular Dial view in History; observe 24-hour circular ring with colored session arcs.

---

### IMP-316: Day Detail Sheet Longest Focus Block Trophy Card
- **Category:** Delight / Motivation
- **Current behaviour:** `DayDetailSheet` computes `longestSessionMs` (`line 94`), but only shows it as a generic number.
- **Proposed improvement:** Display an illuminated milestone chip: `"🏆 Longest Deep Work Block: 3h 15m (Deep Focus)"` with gentle gradient backing.
- **User benefit:** Immediate recognition and pride for sustained attention spans.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:140`
- **Verification:** Open Day Detail for day with 3h session; confirm highlight card showcases longest focus block.

---

### IMP-317: Time Reflection Sheet Audio Note Quick Recorder Integration
- **Category:** Multimedia / UX
- **Current behaviour:** `TimeReflectionSheet` offers text journaling only.
- **Proposed improvement:** Add a 1-tap voice reflection button to record verbal evening reflections without typing on a virtual keyboard.
- **User benefit:** Expressive, effortless evening journaling when tired after a long workday.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:85`
- **Verification:** Open Time Reflection; tap mic button; record voice reflection; verify audio attaches to the daily wrap-up note.

---

### IMP-318: Search Index Service Lazy Asynchronous Tokenization
- **Category:** Performance / Architecture
- **Current behaviour:** In `lib/services/search_index_service.dart:50-80`, index rebuilding on app launch iterates over all moments synchronously on the main thread, which can cause micro-stutter if the database contains 10,000+ entries.
- **Proposed improvement:** Chunk index building in background batches of 500 items using `Future.delayed(Duration.zero)` yield points.
- **User benefit:** Guarantees zero UI thread blocking on databases with years of dense notes.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/search_index_service.dart:65`
- **Verification:** Load mock database with 15,000 moments; monitor frame rate during launch; verify smooth 60fps responsiveness.

---

### IMP-319: History Calendar View Jump to Specific Date Calendar Picker
- **Category:** Navigation / Convenience
- **Current behaviour:** In `HistoryCalendarView`, navigating back 6 months requires swiping across 180 individual day pages.
- **Proposed improvement:** Tapping the month title in the header opens a compact month/year calendar picker dialog that jumps directly to any selected date.
- **User benefit:** Instant navigation to any day in history in 2 taps.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/widgets/history_calendar_view.dart:140`
- **Verification:** Tap "November 2026" header; select "June 14"; verify calendar view instantly jumps to June 14.

---

### IMP-320: Smart Search Filter Match Count Tabular Badge
- **Category:** Visual Polish
- **Current behaviour:** In `lib/dialogs/search_dialogs.dart`, search result count reads `"12 results"`.
- **Proposed improvement:** Style result count as a sleek rounded pill `[ 12 ]` with tabular figures and zero-result friendly guidance.
- **User benefit:** Clean visual clarity when scanning search results.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P3
- **Implementation location:** `lib/dialogs/search_dialogs.dart:150`
- **Verification:** Perform search; observe neat monospaced count badge in search header.

---

### IMP-321: Executive Intelligence Hub Category Time Allocation Donut Chart
- **Category:** Visual Polish / Analytics
- **Current behaviour:** Category distributions are shown as linear progress bars in `ExecutiveDashboardWidgets`.
- **Proposed improvement:** Add an interactive SVG donut chart with subtle slice separation and tap-to-inspect category tooltips.
- **User benefit:** Elegant, publication-grade executive analytics matching modern health and financial dashboards.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/executive_dashboard_widgets.dart:180`
- **Verification:** View Executive Hub; inspect category donut chart; tap slices to see exact hours and percentages.

---

### IMP-322: History Analytics Card Week-over-Week Variance Delta
- **Category:** Analytics / UX
- **Current behaviour:** In `lib/widgets/history_analytics_card.dart:60-90`, weekly analytics display total hours, but do not show the percentage change compared to the previous week.
- **Proposed improvement:** Display a delta pill: `"+14% vs previous week (↑ 4.2h)"` in green or `"-8%"` in subtle text2.
- **User benefit:** Contextual momentum feedback: immediately know whether your focus volume is expanding.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/history_analytics_card.dart:75`
- **Verification:** Compare weekly analytics; verify accurate delta calculations against the preceding 7-day period.

---

### IMP-323: Daily Wrap-Up Evening Wind-Down Notification Trigger
- **Category:** Android System Integration / Routine
- **Current behaviour:** Daily wrap-up must be manually remembered and opened by the user.
- **Proposed improvement:** Add an optional scheduled reminder: `Evening Reflection Prompt at 21:30` that fires a gentle silent notification: `"Review today's journey & seal your ledger"`.
- **User benefit:** Establishes a peaceful, consistent evening journaling and shutdown routine.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:160`
- **Verification:** Set evening wrap-up notification for 21:00; verify notification arrives with 1-tap "Open Wrap-Up" action.

---

### IMP-324: Search Dialogs Date Range Filter Preset Chips ("This Week", "Last Month")
- **Category:** Convenience / UX
- **Current behaviour:** Filtering search results by date requires typing or selecting manual date boundaries.
- **Proposed improvement:** Add quick 1-tap date chips above search results: `[Today]`, `[This Week]`, `[This Month]`, `[Past 90 Days]`.
- **User benefit:** Filter search results chronologically in 1 tap.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/search_dialogs.dart:125`
- **Verification:** Search for "meeting"; tap `[This Week]`; verify only this week's meeting notes appear.

---

### IMP-325: Day Detail Sheet Hourly Bar Tap-to-Filter Moments
- **Category:** Functional Intelligence
- **Current behaviour:** In `DayDetailSheet`, tapping an hour bar (e.g. 14:00) does nothing.
- **Proposed improvement:** Tapping an hour bar filters the moment list below to show only the moments logged during that specific hour.
- **User benefit:** Rapid forensic timeline inspection of specific hours of the day.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:115`
- **Verification:** Tap 14:00 bar in Day Detail; confirm moment list below instantly isolates moments logged between 14:00 and 14:59.

---

### IMP-326: Executive Hub Circadian Rhythm Chronotype Analysis
- **Category:** Functional Intelligence / Health
- **Current behaviour:** Executive Hub shows hours per day, but does not identify the user's natural peak performance chronotype.
- **Proposed improvement:** Compute peak cognitive output hours: `"Chronotype Insight: You achieve 68% of deep work between 08:00 and 11:30 AM (Lark / Morning Focus Profile)"`.
- **User benefit:** Science-backed self-knowledge enabling users to schedule complex tasks during their natural peak cognitive windows.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:210`
- **Verification:** View Executive Hub after 30 days of logging; observe calculated chronotype focus profile.

---

### IMP-327: History Dialog Filter Active Sticky Banner with Dismiss Detent
- **Category:** UX / Polish
- **Current behaviour:** When a timeline filter is active in `HistoryDialog`, a small chip shows at top. Users can forget that a filter is hiding 90% of their history.
- **Proposed improvement:** Display an unmistakable sticky amber banner: `"Filtered by #deepwork (12 moments) [Clear Filter ×]"`.
- **User benefit:** Eliminates user panic wondering where the rest of their historical logs went.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/history_dialog.dart:185`
- **Verification:** Apply filter; verify bright sticky banner clearly states filter criteria with instant 1-tap clear button.

---

### IMP-328: Digital Wellbeing Card Ambient Distraction Interception Metric
- **Category:** Digital Health / Wellbeing
- **Current behaviour:** `DigitalWellbeingCard` tracks screen unlocks, but does not correlate unlocks with broken focus sessions.
- **Proposed improvement:** Correlate Android unlock receiver data with active sessions: `"3 Phone Checks during Deep Focus session (12 min disruption impact)"`.
- **User benefit:** Eye-opening awareness of how micro-phone checks fragment sustained attention.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/digital_wellbeing_card.dart:90`
- **Verification:** Start session, lock and unlock phone twice; view Digital Wellbeing card; observe logged focus interruptions.

---

### IMP-329: Time Reflection Sheet Weekly Mood Trajectory Trend
- **Category:** Mindfulness / Analytics
- **Current behaviour:** `TimeReflectionSheet` records mood emoji, but cannot show weekly emotional trends.
- **Proposed improvement:** Render a 7-day emotional wave trajectory sparkline showing mood shifts across the week.
- **User benefit:** Clear visual correlation between workload, sleep hours, and emotional well-being.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:110`
- **Verification:** Log daily moods for 5 days; open Time Reflection; view weekly mood trajectory sparkline.

---

### IMP-330: History Calendar View Swipe Left on Today Resistance Bounce
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** In `HistoryCalendarView`, swiping left on Today's date page attempts to swipe into tomorrow (future), encountering an abrupt hard stop.
- **Proposed improvement:** Apply an Apple-style rubber-band bounce curve with a subtle caption tooltip: `"No future logs • Today is the frontier"`.
- **User benefit:** Delightful, physical touch boundary communicating that future days cannot be browsed.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:102`
- **Verification:** Swipe left on Today's page; observe gentle elastic rubber-band rebound with frontier caption.

---

### IMP-331: Smart Search Fuzzy Match for Typo Tolerance
- **Category:** Search Intelligence
- **Current behaviour:** In `SearchIndexService`, searching for "meetng" (missing 'i') returns 0 results.
- **Proposed improvement:** Implement Levenshtein distance-1 fuzzy matching for query tokens longer than 4 characters in `SmartSearchFilter`.
- **User benefit:** Effortlessly finds relevant notes even when users make minor typing slips on mobile keyboards.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/services/smart_search_filter.dart:90`
- **Verification:** Search for "wrkout"; confirm moments tagged "#workout" are intelligently matched and returned.

---

### IMP-332: Executive Hub Sunday Dispatch Auto-Generation Summary Card
- **Category:** Reporting / Convenience
- **Current behaviour:** `SundayDispatchSheet` must be opened manually on Sundays.
- **Proposed improvement:** On Sunday evenings, display a prominent "Your Weekly Executive Dispatch is Ready" hero card at the top of the Executive Hub.
- **User benefit:** Seamless weekly executive review habit built directly into the Sunday routine.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:230`
- **Verification:** Open app on Sunday evening; observe glowing Executive Dispatch card ready for 1-tap review.

---

### IMP-333: Day Detail Sheet Total Rest vs Active Work Ratio Gauge
- **Category:** Visual Polish / Balance
- **Current behaviour:** `DayDetailSheet` shows total tracked time, but doesn't visualize balance between work and rest.
- **Proposed improvement:** Render a 2-tone balanced scale gauge: `[Active Focus: 6.2h] vs [Rest & Recovery: 7.8h]`.
- **User benefit:** Promotes healthy life balance by celebrating rest and restorative downtime equally alongside work.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:160`
- **Verification:** View Day Detail; inspect balanced ratio bar showing harmonious work vs recovery hours.

---

### IMP-334: Search Notes Sort Order Toggle (Newest / Oldest / Longest)
- **Category:** Functional / UX
- **Current behaviour:** In `NoteSearchContent`, search results are always sorted by descending timestamp.
- **Proposed improvement:** Add a sort pill selector: `Sort: Newest First | Oldest First | Longest Duration`.
- **User benefit:** Locate marathon deep work sessions or find early project origins with a single tap.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/search_dialogs.dart:165`
- **Verification:** Search for "Design"; switch sort to 'Longest Duration'; verify 4-hour design sessions appear first.

---

### IMP-335: Executive Hub Memento Mori Interactive Week Milestone Tapping
- **Category:** Mindfulness / Depth
- **Current behaviour:** In the Memento Mori 90-year week grid, squares are static colored pixels.
- **Proposed improvement:** Tapping any historical week square displays the user's age during that week and any life milestones recorded in NoteKar during that specific year.
- **User benefit:** Powerful, emotional life ledger perspective connecting current daily moments to the grand tapestry of life.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:195`
- **Verification:** Tap week square corresponding to age 25; see popover showing exact year and life milestones.

---

### IMP-336: Daily Wrap-Up Tomorrow's Top 3 Intentions Field
- **Category:** Productivity / Planning
- **Current behaviour:** `DailyWrapupPage` focuses strictly on reviewing today's past logs.
- **Proposed improvement:** Add an optional "Tomorrow's Top 3 Intentions" section. Tomorrow's intentions appear as a subtle reminder on tomorrow morning's home screen.
- **User benefit:** Wake up with crystalline clarity on the day's primary missions already defined the night before.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:180`
- **Verification:** Enter 3 intentions in Daily Wrap-Up; wake up next morning; observe intentions displayed in home dynamic header.

---

### IMP-337: History Calendar View Day Strip Swipe Haptic Velocity Scaling
- **Category:** Tactile Feedback
- **Current behaviour:** Swiping fast across multiple days in the date strip produces a single click or silent movement.
- **Proposed improvement:** Provide variable haptic resistance: fast flings produce a light rotary buzz (`selectionClick()` every 3 days), slowing to single clicks on deceleration.
- **User benefit:** Premium mechanical rotary feel matching high-end camera dials or Leica watch crowns.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:115`
- **Verification:** Fling date strip quickly; feel smooth mechanical rotary click decay as the strip coasts to a stop.

---

### IMP-338: Smart Search Category Pill Quick Filter Multi-Select
- **Category:** Search Intelligence / UX
- **Current behaviour:** In `NoteSearchContent:98`, category filters are single-select only.
- **Proposed improvement:** Support multi-select category chips: filter simultaneously by `[Work]` and `[Writing]`.
- **User benefit:** Cross-cutting search across complementary life domains.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/search_dialogs.dart:135`
- **Verification:** Select both 'Work' and 'Writing' chips in search; verify results include moments from both categories.

---

### IMP-339: Day Detail Sheet Note Word Count Aggregate Total
- **Category:** Analytics / Reporting
- **Current behaviour:** `DayDetailSheet` aggregates durations, but does not calculate total words written across the day's notes.
- **Proposed improvement:** Display an aggregate badge: `"✍️ 1,420 Words Journaled Today Across 6 Moments"`.
- **User benefit:** Tremendously motivating for writers, researchers, and reflective journalers.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:150`
- **Verification:** Log three 200-word notes; view Day Detail; confirm "600 Words Journaled" metric displays accurately.

---

### IMP-340: Executive Hub Activity Ring Target Customization
- **Category:** Personalization / Flexibility
- **Current behaviour:** In `ExecutiveIntelligenceHubScreen`, the activity ring target defaults to 8 hours daily.
- **Proposed improvement:** Allow users to calibrate their daily target hours: `4h (Part-Time / Student) | 6h | 8h (Standard) | 10h (Intensive)`.
- **User benefit:** Ring completion matches personal lifestyle and realistic capacity.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:110`
- **Verification:** Change daily target to 6 hours; log 6 hours; verify Activity Ring closes to 100% completion.

---

### IMP-341: Search Dialogs Highlighted Match Context Line Clamping
- **Category:** Visual Polish / UX
- **Current behaviour:** In search results, if the matched word appears on line 50 of a long note, the result card shows lines 1-4, hiding the actual match off-screen.
- **Proposed improvement:** Center the search result preview snippet directly around the matched line with `...` before and after.
- **User benefit:** Instant visual verification of matched context without tapping into the full note.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/search_dialogs.dart:155`
- **Verification:** Search for keyword on line 40 of long note; confirm result preview snippet displays lines 39-41.

---

### IMP-342: History Dialog Empty Search Results "Create New Moment" Action
- **Category:** User Flows / UX
- **Current behaviour:** When search returns 0 results in `HistoryDialog`, a static empty message is shown.
- **Proposed improvement:** Add a primary action button in the empty state: `"Log New Moment with this query [Query]"` that opens the note composer prefilled with the search term.
- **User benefit:** Frictionless workflow: searched for a thought you haven't logged yet? Log it immediately in 1 tap.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/history_dialog.dart:210`
- **Verification:** Search for non-existent keyword "Quantum Physics"; tap 'Log New Moment'; verify composer opens prefilled.

---

### IMP-343: Time Reflection Sheet Morning vs Evening Reflection Tabs
- **Category:** Routine / Mindfulness
- **Current behaviour:** `TimeReflectionSheet` focuses on evening wrap-up.
- **Proposed improvement:** Add two dedicated reflection tabs: `[Morning Intention 🌅]` (gratitude, focus plan) and `[Evening Review 🌙]` (celebrations, lessons).
- **User benefit:** Complete morning-to-night mindful journaling framework inspired by the 5-Minute Journal.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:60`
- **Verification:** Open Time Reflection in morning; see Morning Intention prompts; open at night to see Evening Review prompts.

---

### IMP-344: Executive Hub Focus Category Rhythm 7-Day Stacked Bar Chart
- **Category:** Analytics / Visual Polish
- **Current behaviour:** In `ExecutiveDashboardWidgets`, weekly category breakdown is shown as aggregate numbers.
- **Proposed improvement:** Render a 7-day stacked bar chart showing daily category breakdowns (e.g. Monday: 4h Work, 2h Study; Tuesday: 5h Work, 1h Exercise).
- **User benefit:** Granular day-by-day visualization of how focus shifted throughout the week.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/executive_dashboard_widgets.dart:210`
- **Verification:** Inspect 7-day chart in Executive Hub; observe proportional stacked colored bars for each day.

---

### IMP-345: History Calendar View Quick Jump to Today Hero Button
- **Category:** Navigation / Convenience
- **Current behaviour:** When browsed 30 days back in `HistoryCalendarView`, jumping back to Today requires tapping the date strip or swiping 30 times.
- **Proposed improvement:** Display a floating `"Jump to Today"` capsule button in the bottom corner when viewed date != today.
- **User benefit:** 1-tap instant return to the current day from any point in history.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/widgets/history_calendar_view.dart:160`
- **Verification:** Scroll 20 days back in calendar view; tap floating 'Jump to Today' capsule; verify view snaps back to today instantly.

---

### IMP-346: Smart Search Chips Bar Horizontally Scrollable Tag Strip
- **Category:** UX / Polish
- **Current behaviour:** In `lib/widgets/smart_search_chips_bar.dart:25-50`, tag chips wrap to multiple lines, taking up 40% of the screen height above search results.
- **Proposed improvement:** Make the tag chips bar a single-line horizontal scrollable strip with 8dp spacing and subtle edge fade.
- **User benefit:** Maximizes vertical screen real estate for viewing actual search result cards.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/smart_search_chips_bar.dart:32`
- **Verification:** Open search with 15 tags; confirm tags scroll horizontally on a single 36dp line without taking over screen.

---

### IMP-347: Day Detail Sheet Session Timeline Gap Visual Warning
- **Category:** Visual Polish / Data Integrity
- **Current behaviour:** In `DayDetailSheet`, gaps between sessions are invisible in the list.
- **Proposed improvement:** If an untracked gap > 1 hour exists between sessions, render a subtle dotted warning divider: `"[ · · · 2h 15m untracked gap · · · ]"`.
- **User benefit:** Visual clarity highlighting unaccounted-for time blocks during daily retrospectives.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:170`
- **Verification:** View Day Detail with 2-hour gap between morning and afternoon; observe dotted gap indicator.

---

### IMP-348: Executive Hub Sleep Deficit & Recovery Correlation
- **Category:** Health / Analytics
- **Current behaviour:** Sleep is logged as generic hours in `UniversalIntervalLedger`.
- **Proposed improvement:** Correlate sleep hours with next-day deep focus productivity: `"Sleep Correlation: Following 7.5+ hours of sleep, your deep work output increases by 34%"`.
- **User benefit:** Deep neurological motivation prioritizing restorative sleep as the foundation of peak focus.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:240`
- **Verification:** View Executive Hub with 30 days of sleep data; observe calculated sleep vs productivity correlation card.

---

### IMP-349: Daily Wrap-Up Closing Ritual Celebration Haptic
- **Category:** Delight / Closure
- **Current behaviour:** Tapping "Seal Day's Record" closes the wrap-up page with a basic pop.
- **Proposed improvement:** Trigger a rich, ceremonial three-stage haptic heartbeat (`AppHaptics.heavy()` followed by soft reverberation) as the day is sealed.
- **User benefit:** Dignified psychological closure ending the workday and mentally transitioning to rest.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:195`
- **Verification:** Tap 'Seal Day's Record'; feel the profound ceremonial haptic sequence signaling day's completion.

---

### IMP-350: History Analytics Card Clean Bar Value Tooltips
- **Category:** Visual Polish
- **Current behaviour:** In `HistoryAnalyticsCard`, bar charts show heights without explicit number values on small screens.
- **Proposed improvement:** Tapping any daily bar in the 7-day analytics card displays an instant floating badge showing exact hours (e.g. `6.8h`).
- **User benefit:** Exact numerical clarity without guessing bar heights against the y-axis grid.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_analytics_card.dart:95`
- **Verification:** Tap Wednesday bar in analytics card; observe exact `5.2h` tooltip appear above bar.

---

### IMP-351: Search Dialogs Exact Phrase Matching Quotes (`"exact phrase"`)
- **Category:** Search Intelligence
- **Current behaviour:** In `SearchIndexService`, searching for `"deep focus"` matches notes containing "deep" OR "focus" anywhere.
- **Proposed improvement:** Support quotation marks for exact literal multi-word phrase matching.
- **User benefit:** High-precision search for exact quotes, meeting attendees, or specific book titles.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/smart_search_filter.dart:80`
- **Verification:** Search for `"quarterly review"`; confirm only moments containing that exact sequence of words are returned.

---

### IMP-352: Timeline Filter Sheet Multi-Hashtag Boolean Filter (`AND` vs `OR`)
- **Category:** Filter Intelligence / Power Users
- **Current behaviour:** Selecting multiple hashtags in `TimelineFilterSheet` defaults to `OR` matching.
- **Proposed improvement:** Add a toggle: `Match Tags: ANY (OR) | ALL (AND)`.
- **User benefit:** Power users can isolate moments tagged both `#work` AND `#urgent`.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/timeline_filter_sheet.dart:90`
- **Verification:** Select `#work` and `#client`; toggle to 'ALL (AND)'; confirm only moments with both tags appear.

---

### IMP-353: Executive Hub Digital Wellbeing App Screen Time Correlation
- **Category:** Digital Health
- **Current behaviour:** `DigitalWellbeingService` reads Android usage stats, but displays them in a separate isolated card.
- **Proposed improvement:** Cross-reference screen time with focus time: `"Ratio: 4.5h Deep Work vs 1.8h Social Screen Time (71% Intentional)"`.
- **User benefit:** Invaluable ratio revealing whether the smartphone was used as a tool or a distraction.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:260`
- **Verification:** Grant usage stats permission; inspect Executive Hub; view calculated Intentional Work vs Distraction ratio.

---

### IMP-354: Day Detail Sheet Earliest & Latest Activity Boundary Metrics
- **Category:** Functional Intelligence
- **Current behaviour:** `DayDetailSheet` shows total time, but doesn't highlight start and wrap-up times.
- **Proposed improvement:** Display clear day boundary bookends: `"First Log: 06:14 AM • Last Log: 22:45 PM (16.5h Waking Span)"`.
- **User benefit:** Understand daily waking span and sleep schedule boundaries at a glance.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:130`
- **Verification:** View Day Detail; confirm First Log and Last Log timestamps are clearly stated.

---

### IMP-355: Time Reflection Sheet One-Sentence Journaling Prompt
- **Category:** Productivity / Mindfulness
- **Current behaviour:** The reflection field is a large empty box, which can feel intimidating when tired.
- **Proposed improvement:** Offer a "One-Sentence Journal" prompt option: `"Summarize today in a single sentence."` with a 140-character constraint.
- **User benefit:** Zero-friction daily reflection habit that takes literally 15 seconds to complete.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:90`
- **Verification:** Toggle One-Sentence mode in Time Reflection; type a single concise sentence; save effortlessly.

---

### IMP-356: History Calendar View Smooth Momentum Header Pinning
- **Category:** Visual Polish
- **Current behaviour:** In `HistoryCalendarView`, the sticky day header can jitter slightly on rapid upward scroll.
- **Proposed improvement:** Pin the date header with `SliverPersistentHeader` using an explicit hairline divider and continuous squircle backdrop blur.
- **User benefit:** Flawless, jitter-free header pinning during intense scroll operations.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:130`
- **Verification:** Scroll day timeline rapidly; observe rock-solid, vibration-free date header pinning.

---

### IMP-357: Search Dialogs Media Attachment Type Filter Icons
- **Category:** Search Intelligence
- **Current behaviour:** Users cannot easily filter search to find "Notes with Photos" or "Notes with Voice Memos".
- **Proposed improvement:** Add quick media filter chips in search: `[📷 Photos Only]` and `[🎙️ Voice Notes Only]`.
- **User benefit:** Instant retrieval of audio recordings or whiteboard snapshots without remembering exact text words.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/search_dialogs.dart:120`
- **Verification:** Tap `[🎙️ Voice Notes]` chip in search; verify timeline displays only moments containing audio recordings.

---

### IMP-358: Executive Hub Monthly Milestone Growth Trajectory Chart
- **Category:** Analytics / Motivation
- **Current behaviour:** Monthly view in Executive Hub shows total hours, but lacks a cumulative growth trajectory curve.
- **Proposed improvement:** Add an S-curve cumulative hours trajectory line showing days 1-31 progression toward the monthly target.
- **User benefit:** Clear visual indicator whether monthly volume is accelerating or plateauing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:150`
- **Verification:** Switch to Month view in Executive Hub; inspect cumulative hours S-curve line chart.

---

### IMP-359: Daily Wrap-Up Gratitude 3-Item Quick Bullets
- **Category:** Mindfulness / Wellbeing
- **Current behaviour:** Wrap-up prompts are generic text notes.
- **Proposed improvement:** Add an optional "3 Gratitudes" expander with three clean bullet lines: `1.`, `2.`, `3.`.
- **User benefit:** Clinically proven positive psychology practice embedded seamlessly into the evening wrap-up.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:170`
- **Verification:** Expand 3 Gratitudes in wrap-up; enter three quick highlights; save into daily reflection record.

---

### IMP-360: History Calendar View Weekend Column Visual Tint
- **Category:** Visual Polish / Calendar
- **Current behaviour:** In the horizontal date strip, Saturdays and Sundays look identical to workdays.
- **Proposed improvement:** Subtly tint weekend date numbers in soft lavender or accent alpha (`0.75`), with a delicate dot under Saturday and Sunday.
- **User benefit:** Immediate visual orientation when scrolling through multi-week historical calendars.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:108`
- **Verification:** Inspect horizontal date strip; observe distinct weekend styling distinguishing Sat/Sun from weekdays.

---

### IMP-361: Search Notes Full-Text Search Highlight Match Navigation (1 of 7)
- **Category:** Productivity / Power Users
- **Current behaviour:** In `NotePreviewSheet`, search matches are highlighted, but users must manually scroll to find matches buried deep in long notes.
- **Proposed improvement:** Add an Apple Safari-style match navigation bar: `"3 of 8 [▲] [▼]"` that auto-scrolls between highlighted matches in the note.
- **User benefit:** Rapid scanning of massive 3,000-word research notes or legal summaries.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_preview_sheet.dart:160`
- **Verification:** Search long note; tap next arrow; verify viewport smoothly scrolls to center the second match.

---

### IMP-362: Day Detail Sheet Category Percentage Bar Tap Sound
- **Category:** Audio / Polish
- **Current behaviour:** Tapping category percentage breakdown bars in `DayDetailSheet` is completely silent.
- **Proposed improvement:** Play a crisp selection tick (`AppHaptics.select()`) on category bar taps.
- **User benefit:** Responsive, tactile interactive analytics feeling.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P3
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:135`
- **Verification:** Tap category bar in Day Detail; confirm light haptic tick accompanies inspection popover.

---

### IMP-363: Executive Hub Habit Adherence Correlation with Deep Focus
- **Category:** Analytics / Insights
- **Current behaviour:** Habit checkpoints and focus sessions are tracked in separate silos.
- **Proposed improvement:** Correlate habit execution with daily focus: `"Routine Impact: On days when Morning Walk is completed, your deep work increases by 45 minutes"`.
- **User benefit:** Proves with personal mathematical data that keystone morning habits supercharge daily productivity.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:270`
- **Verification:** Inspect Executive Hub insights; read calculated keystone habit correlation card.

---

### IMP-364: Timeline Filter Sheet Active Category Color Dot Indicator
- **Category:** Visual Polish
- **Current behaviour:** Category options in `TimelineFilterSheet` display plain text titles.
- **Proposed improvement:** Prefix each filter category option with its vibrant squircle color dot matching the home screen.
- **User benefit:** Consistent visual language that makes category recognition instantaneous.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/timeline_filter_sheet.dart:75`
- **Verification:** Open Timeline Filter; verify colored squircle dots beside Work, Deep Focus, and Personal categories.

---

### IMP-365: Daily Wrap-Up Day Grade Visual Badge (A+ / Solid / Recovery)
- **Category:** Gamification / Motivation
- **Current behaviour:** The wrap-up calculates metrics but offers no qualitative closing score.
- **Proposed improvement:** Compute a gentle, private "Daily Rhythm Rating": `Solid Focus ★★★`, `High Momentum ★★★★`, or `Recovery & Rest 🌿`.
- **User benefit:** Wholesome, encouraging closure summarizing daily intentionality without toxic gamification.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:210`
- **Verification:** Complete 6 hours of work; seal day; observe positive 'High Momentum' summary badge.

---

### IMP-366: History Calendar View Empty Day Gentle Illustration
- **Category:** Visual Polish / Onboarding
- **Current behaviour:** In `HistoryCalendarView`, a day with 0 moments displays a stark blank screen with generic text.
- **Proposed improvement:** Render an elegant, peaceful Apple-style minimal line illustration with a soft caption: `"An unscripted day • No moments recorded"`, with a "Log Past Session" button.
- **User benefit:** Beautiful, non-judgmental empty state that invites mindful retroactive logging.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:180`
- **Verification:** Swipe to an empty day in History; observe serene empty state illustration with 1-tap manual log action.

---

### IMP-367: Search Dialogs Case-Sensitive Search Option Toggle
- **Category:** Search Intelligence / Power Users
- **Current behaviour:** All searches in `SearchIndexService` are strictly case-insensitive.
- **Proposed improvement:** Add an optional `[Aa]` toggle button in the search bar to enforce exact case matching (e.g. matching `API` but not `api`).
- **User benefit:** Essential precision searching for software engineers and technical documentation authors.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/search_dialogs.dart:105`
- **Verification:** Toggle `[Aa]` button; search for "iOS"; confirm lowercase "ios" is excluded from results.

---

### IMP-368: Executive Hub Memento Mori Fullscreen Zen Zoom
- **Category:** Mindfulness / Visual Polish
- **Current behaviour:** The Memento Mori life grid is constrained inside a scrollable card.
- **Proposed improvement:** Tapping the Memento Mori card expands it into a fullscreen, distraction-free cosmic contemplation canvas with soft ambient glow.
- **User benefit:** Immersive philosophical perspective reflecting on the brevity and preciousness of human life.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:200`
- **Verification:** Tap Memento Mori card; watch it smoothly expand into a fullscreen cosmic mortality horizon canvas.

---

### IMP-369: Time Reflection Sheet Weekly Export to Sovereign Markdown Vault
- **Category:** Export / Data Sovereignty
- **Current behaviour:** Reflections live inside the Isar database only.
- **Proposed improvement:** Add a "Sync Reflections to Vault" action that compiles the past 7 days of reflections into a clean `Weekly_Reflection_2026_W45.md` file in user storage.
- **User benefit:** Seamless integration into personal Obsidian knowledge vaults and sovereign offline backups.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:130`
- **Verification:** Tap Sync to Vault; verify cleanly formatted weekly markdown report in Documents directory.

---

### IMP-370: History Calendar View Date Strip Today Indicator Glow
- **Category:** Visual Polish
- **Current behaviour:** In the horizontal date strip, "Today" has a tiny dot beneath the number.
- **Proposed improvement:** Encase Today's date in a distinctive, illuminated squircle pill (`p.accent.withValues(alpha: 0.15)`) with bold accent typography.
- **User benefit:** Instant visual anchoring: locate Today on the date strip in 0.1 seconds.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/history_calendar_view.dart:112`
- **Verification:** Inspect date strip; observe illuminated squircle pill surrounding today's date.

---

### IMP-371: Search Notes Negation Operator (`-tag:personal`)
- **Category:** Search Intelligence / Power Users
- **Current behaviour:** Search only supports additive queries. Users cannot exclude specific categories or tags.
- **Proposed improvement:** Support negation syntax: `-tag:personal` or `-cat:admin` to exclude matches from query results.
- **User benefit:** Filter out clutter to focus purely on professional or high-priority items.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/services/smart_search_filter.dart:85`
- **Verification:** Search for `review -cat:admin`; confirm admin review moments are filtered out.

---

### IMP-372: Day Detail Sheet Circular Day Clock Arc Hover Micro-Popovers
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** In the day detail view, touching the session timeline highlights the item, but doesn't show exact duration popovers.
- **Proposed improvement:** Touch-dragging across the timeline displays a floating micro-capsule: `"09:30 - 11:45 • 2h 15m Deep Work"`.
- **User benefit:** Fluid interactive scrubbing through the day's historical events.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:125`
- **Verification:** Drag finger along day timeline bar; observe floating inspection bubble tracking the touch point.

---

### IMP-373: Executive Hub Export Executive PDF / Image Report
- **Category:** Reporting / Professional
- **Current behaviour:** Executive Intelligence Hub data can only be viewed within the app.
- **Proposed improvement:** Add an "Export Executive Summary" action generating an Apple-style 1-page visual executive briefing sheet ready for PDF print or image export.
- **User benefit:** Professional weekly time audit reports ready to submit to clients, advisors, or executives.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:280`
- **Verification:** Tap Export in Executive Hub; generate high-res executive summary PDF ready for sharing.

---

### IMP-374: Daily Wrap-Up Midnight Auto-Close Guard
- **Category:** Reliability / Edge Cases
- **Current behaviour:** If a user opens Daily Wrap-Up at 23:58 and completes it at 00:03, the wrap-up reflection might save under the new day's date rather than yesterday's.
- **Proposed improvement:** Lock the wrap-up date anchor to the day being reviewed upon screen open, regardless of midnight clock rollovers during composition.
- **User benefit:** Preserves 100% accurate date attribution for late-night journal reflections.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:85`
- **Verification:** Open wrap-up at 23:59; save at 00:01; confirm reflection is correctly credited to yesterday's date.

---

### IMP-375: History Analytics Card 30-Day Moving Average Trend Line
- **Category:** Analytics / Precision
- **Current behaviour:** `HistoryAnalyticsCard` displays weekly totals, but cannot smooth out fluctuations.
- **Proposed improvement:** Add a subtle 30-day moving average overlay line running across the weekly bars.
- **User benefit:** Identifies macro-level upward or downward focus trends filtered of daily noise.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_analytics_card.dart:110`
- **Verification:** View 30-day analytics; observe smooth moving average trend line overlaying the bars.

---

### IMP-376: Search Dialogs Tag Multi-Color Pill Rendering
- **Category:** Visual Polish
- **Current behaviour:** In `NoteSearchDialog`, tag chips use a uniform neutral grey color.
- **Proposed improvement:** Color-code tag chips dynamically based on their category association (e.g. Blue for Work tags, Emerald for Health tags).
- **User benefit:** Rich visual categorization making search tags immediately distinct.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/smart_search_chips_bar.dart:45`
- **Verification:** View search chips; observe `#workout` rendered in Emerald and `#coding` rendered in Electric Blue.

---

### IMP-377: Day Detail Sheet Session Note Direct Inline Editing
- **Category:** User Flows / Efficiency
- **Current behaviour:** Editing a note from `DayDetailSheet` requires opening the full NoteDialog modal, editing, and closing.
- **Proposed improvement:** Add an inline "Tap to edit note" expander allowing quick micro-edits directly inside the day detail view.
- **User benefit:** Quick typo correction without disruptive modal navigation transitions.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:185`
- **Verification:** Tap note text in Day Detail; edit single word inline; tap checkmark; verify note updates immediately.

---

### IMP-378: Executive Hub Life Audit Balance Radar Chart
- **Category:** Visual Polish / Innovation
- **Current behaviour:** Life Audit scores are listed as text percentages.
- **Proposed improvement:** Render an Apple HIG-style 6-axis polygonal Radar / Spider Chart showing balance across Work, Health, Mind, Social, Craft, and Rest.
- **User benefit:** Dramatic, intuitive visual balance assessment: immediately spot if Work is crowding out Health or Sleep.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:250`
- **Verification:** Inspect Life Audit in Executive Hub; observe multi-axis polygonal radar chart displaying life balance.

---

### IMP-379: History Calendar View Quick Date Picker Jump to Year Selection
- **Category:** Navigation / Ergonomics
- **Current behaviour:** The date picker modal defaults to scrolling months. Jumping 3 years back requires scrolling through 36 months.
- **Proposed improvement:** Tapping the Year header in the date picker expands a direct Year Grid (e.g. `2024`, `2025`, `2026`) for 1-tap year selection.
- **User benefit:** Jump across multi-year archives in 1 second.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/app_date_picker_sheet.dart:85`
- **Verification:** Tap year in date picker sheet; select '2024'; verify calendar snaps immediately to 2024.

---

### IMP-380: Smart Search Filter Instant Query Cache
- **Category:** Performance / Smoothness
- **Current behaviour:** Repeated searches for identical terms re-execute full text filter sweeps against all moments.
- **Proposed improvement:** Maintain an LRU memory cache of the last 10 search results (`Map<String, List<Moment>> _searchCache`).
- **User benefit:** Instant zero-millisecond search result retrieval when switching back and forth between queries.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/smart_search_filter.dart:110`
- **Verification:** Search "Focus", then "Gym", then "Focus"; confirm second "Focus" search results appear with 0ms latency.

---

### IMP-381: Daily Wrap-Up Tomorrow's Morning Routine Checklist Preview
- **Category:** Routine / Convenience
- **Current behaviour:** `DailyWrapupPage` does not preview tomorrow morning's habit checkpoints.
- **Proposed improvement:** Display tomorrow morning's scheduled habits (`Wake Up`, `Hydration`, `Morning Walk`) as a gentle preview list.
- **User benefit:** Mentally prepares the user for a victorious, disciplined start to the next morning.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:185`
- **Verification:** View Daily Wrap-Up; inspect 'Tomorrow Morning's Rhythm' preview checklist.

---

### IMP-382: Timeline Filter Sheet Active Filter Badge Counter on Main Timeline Button
- **Category:** Discoverability / UX
- **Current behaviour:** When a filter is active, the filter button in the toolbar shows an active color, but doesn't show how many filter criteria are applied.
- **Proposed improvement:** Add a miniature notification dot badge with number: `[Filter ⚙️ (2)]` indicating 2 active criteria.
- **User benefit:** Clear reminder that multiple active constraints are currently filtering the timeline view.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/toolbar.dart:210`
- **Verification:** Apply category and hashtag filters; verify filter icon in toolbar displays neat badge `(2)`.

---

### IMP-383: Day Detail Sheet Longest Focus Block Category Badge
- **Category:** Visual Polish
- **Current behaviour:** In `DayDetailSheet`, the longest focus block shows duration only.
- **Proposed improvement:** Display the category pill badge (e.g. `[Deep Work 🟦]`) directly beside the duration record.
- **User benefit:** Instantly know which project or task type yielded today's highest flow state.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:145`
- **Verification:** Inspect Day Detail highlight card; observe colorful category badge beside longest session duration.

---

### IMP-384: Executive Hub Weekday Focus Distribution Radar Bar Chart
- **Category:** Analytics / Insights
- **Current behaviour:** Executive Hub shows weekly hours, but doesn't highlight whether Tuesdays are systematically more productive than Fridays.
- **Proposed improvement:** Add a "Weekday Distribution Profile" showing average hours logged per weekday over the last 90 days (e.g. Tue μ=6.5h vs Fri μ=3.2h).
- **User benefit:** Optimizes weekly scheduling: schedule deep creative work on Tuesdays and lightweight admin on Fridays.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:220`
- **Verification:** View Executive Hub; observe Weekday Productivity Profile highlighting Tuesday as peak focus day.

---

### IMP-385: Time Reflection Sheet Mood Rating Haptic Sliders
- **Category:** Tactile Feedback / Mindfulness
- **Current behaviour:** Selecting mood in `TimeReflectionSheet` uses static emoji buttons.
- **Proposed improvement:** Add a smooth 5-point energy/mood slider with continuous rising haptic pitch as the slider moves from Low to High energy.
- **User benefit:** Engaging, sensory mood check-in that feels intuitive and pleasant.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:75`
- **Verification:** Slide energy slider from 1 to 5; feel progressive tactile escalation across the 5 stages.

---

### IMP-386: History Calendar View Quick Jump to Oldest First Log
- **Category:** Navigation / Delight
- **Current behaviour:** Reaching the very first day NoteKar was ever used requires scrolling back through hundreds of days.
- **Proposed improvement:** In the calendar date jump dialog, add a dedicated shortcut button: `"Jump to First Log (Origin: Jan 12, 2025)"`.
- **User benefit:** 1-tap emotional journey back to where the user's sovereign life ledger journey began.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:145`
- **Verification:** Tap 'Jump to First Log' in history picker; verify calendar view immediately displays the user's very first logged moment.

---

### IMP-387: Search Notes Match Snippet Line Number Indicator
- **Category:** Productivity / Precision
- **Current behaviour:** In `NoteSearchContent`, matched snippets show text only without indicating where in the note the match occurs.
- **Proposed improvement:** Display subtle line number metadata: `"Line 42: ...agreed on quarterly contract..."`.
- **User benefit:** Essential location context when searching through long structured documents or meeting minutes.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/search_dialogs.dart:158`
- **Verification:** Search long note; observe clean "Line 34" badge beside the preview snippet.

---

### IMP-388: Day Detail Sheet Evening Wind-Down Habit Compliance Indicator
- **Category:** Routine / Health
- **Current behaviour:** Day detail lists moments, but doesn't summarize whether evening wind-down habits (Reading, Screen-Off) were completed.
- **Proposed improvement:** Add a dedicated "Evening Shutdown Rhythm" checklist badge confirming whether evening checkpoints were completed before bedtime.
- **User benefit:** Strong behavioral reinforcement for healthy sleep hygiene.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:190`
- **Verification:** Complete evening reading habit; open Day Detail; confirm Evening Shutdown badge displays green check.

---

### IMP-389: Executive Hub Digital Wellbeing Nighttime Screen Disruption Metrics
- **Category:** Health / Analytics
- **Current behaviour:** Unlocks during sleeping hours are mixed into daytime statistics.
- **Proposed improvement:** Isolate night unlocks (`00:00 - 06:00`): `"Nighttime Phone Checks: 2 unlocks (18 mins awake)"`.
- **User benefit:** Critical sleep hygiene awareness identifying midnight phone use that disrupts deep REM sleep cycles.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/digital_wellbeing_card.dart:110`
- **Verification:** Unlock phone at 02:30 AM; check Digital Wellbeing card; verify night unlock is flagged under Nighttime Checks.

---

### IMP-390: History Calendar View Multi-Day Range Selection for Bulk Export
- **Category:** Export / Power Users
- **Current behaviour:** Exporting CSV or JSON exports either the entire database or single entries.
- **Proposed improvement:** Allow long-pressing and dragging across multiple days on the calendar strip to select a custom date range (e.g. Oct 1 to Oct 15) for targeted CSV export.
- **User benefit:** Perfect client billing exports: export exactly the two-week sprint period for invoice attachment.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/history_calendar_view.dart:170`
- **Verification:** Select 7 days in history; tap 'Export Selected Days as CSV'; confirm clean CSV file containing only those 7 days.

---

### IMP-391: Daily Wrap-Up Intentional Focus Ratio Celebration Sparkle
- **Category:** Delight / Visual Polish
- **Current behaviour:** In `DailyWrapupPage`, reaching >80% intentional time displays a text percentage.
- **Proposed improvement:** When intentionality is ≥85%, render a subtle celebratory emerald halo sparkle around the percentage gauge.
- **User benefit:** Immediate sensory gratification rewarding disciplined, focused work days.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart:145`
- **Verification:** Complete day with 90% intentional ratio; open wrap-up; observe radiant emerald celebration halo.

---

### IMP-392: Search Notes Search Field Clear "×" Button Haptic Click
- **Category:** Tactile Feedback
- **Current behaviour:** In `NoteSearchContent:94`, tapping the clear "×" icon in the search bar clears text silently.
- **Proposed improvement:** Fire `HapticFeedback.lightImpact()` as the search textfield clears.
- **User benefit:** Crisp, tactile confirmation that the search query has been erased.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P3
- **Implementation location:** `lib/dialogs/search_dialogs.dart:100`
- **Verification:** Tap '×' in search bar; feel light tactile click as input field clears.

---

### IMP-393: Day Detail Sheet Ambient Noise & Acoustic Feedback Log
- **Category:** Multimedia / Context
- **Current behaviour:** Voice notes on a day show up as isolated audio pills.
- **Proposed improvement:** Summarize cumulative voice memos recorded today: `"3 Voice Memos • 8m 42s total audio recorded"`.
- **User benefit:** Glanceable summary of all auditory thoughts captured throughout the day.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:155`
- **Verification:** Record two voice memos today; view Day Detail; confirm audio summary badge displays total memo count and runtime.

---

### IMP-394: Executive Hub Memento Mori Weeks Lived vs Remaining Counter
- **Category:** Typography / Polish
- **Current behaviour:** Memento Mori displays numbers in standard font weights.
- **Proposed improvement:** Display tabular monospace metrics: `[ 1,824 Weeks Lived • 2,336 Weeks Remaining ]` with high-contrast numerical tracking.
- **User benefit:** Stark, sober, and elegant mathematical perspective on finite human existence.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:185`
- **Verification:** Inspect Memento Mori header; confirm clean tabular figure metrics.

---

### IMP-395: Timeline Filter Sheet Reset on Dialog Dismiss Option
- **Category:** Settings / Flexibility
- **Current behaviour:** If a user filters history and closes the dialog, the filter stays active forever until manually cleared.
- **Proposed improvement:** Add an option: `Auto-Clear Filters When Exiting History`.
- **User benefit:** Ensures the user always returns to the complete full timeline on their next visit.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/timeline_filter_sheet.dart:95`
- **Verification:** Enable setting; apply filter; close history; reopen history; verify full timeline displays automatically.

---

### IMP-396: Time Reflection Sheet Morning Journaling Reminder Exact Alarm
- **Category:** Android System Integration / Routine
- **Current behaviour:** Morning journaling relies on spontaneous memory.
- **Proposed improvement:** Schedule an exact alarm reminder for 07:00 AM: `"Morning Intention: Define your single primary focus today"`.
- **User benefit:** Cultivates an intentional, proactive start to every morning before reactive emails intrude.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart:140`
- **Verification:** Set morning intention reminder; receive quiet, sovereign local alert at 07:00 AM.

---

### IMP-397: History Calendar View Swiping Page Shadow Depth
- **Category:** Visual Polish
- **Current behaviour:** In `HistoryCalendarView`, swiping between days looks like flat cards sliding horizontally.
- **Proposed improvement:** Add a subtle vertical drop shadow along the trailing edge of the sliding day page (`offset: Offset(-4, 0), blurRadius: 16, color: Colors.black26`).
- **User benefit:** Physical depth and separation between adjacent calendar day pages.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/history_calendar_view.dart:125`
- **Verification:** Swipe slowly between days; observe delicate 3D page edge shadow separating yesterday from today.

---

### IMP-398: Search Notes Search Field Automatic Keyboard Lowering on Scroll
- **Category:** Ergonomics / Keyboard Integration
- **Current behaviour:** When scrolling through search results, the virtual keyboard stays open, obscuring 50% of the result list.
- **Proposed improvement:** Attach `KeyboardDismissBehavior.onDrag` to the search results `ListView`.
- **User benefit:** Soft keyboard dismisses naturally the instant the user begins scrolling through results.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/search_dialogs.dart:170`
- **Verification:** Perform search; drag finger down to scroll results; confirm virtual keyboard tucks away smoothly.

---

### IMP-399: Day Detail Sheet Circular Day Clock Arc Category Tooltip Touch
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** Tapping a section arc on the day clock diagram highlights the moment in the list below, but provides no visual card above the dial.
- **Proposed improvement:** Highlight the selected arc with an outer glowing ring and display an illuminated category badge directly in the center of the clock dial.
- **User benefit:** Interactive circular horology inspection matching professional aviation instruments.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/day_detail_sheet.dart:138`
- **Verification:** Tap afternoon arc on day clock; watch illuminated category title appear in center of dial.

---

### IMP-400: Executive Hub Intelligence Summary Card Copy to Clipboard
- **Category:** Convenience / Reporting
- **Current behaviour:** Executive summary metrics can only be read on screen.
- **Proposed improvement:** Add a "Copy Executive Briefing" button in the Hub header that formats the week's statistics into a clean, professional text summary:
  ```
  📊 NoteKar Executive Focus Briefing (Nov 2 - Nov 8)
  • Total Tracked: 38h 15m (79% Intentional)
  • Top Category: Deep Focus (18h 30m)
  • Habit Adherence: 94% Consistency
  • Peak Cognitive Window: 08:30 - 11:30 AM
  ```
- **User benefit:** 1-tap paste into email updates to managers, coaching groups, or private weekly reviews.
- **Implementation effort:** 1
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/screens/executive_intelligence_hub_screen.dart:290`
- **Verification:** Tap 'Copy Briefing' in Executive Hub; paste into text editor; verify beautifully formatted weekly summary.
