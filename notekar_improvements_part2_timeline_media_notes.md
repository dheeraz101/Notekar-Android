# NoteKar 500+ Micro-Improvements Inventory: Part 2
## Focus Area: Timeline, Moments, Media Attachments (Photos & Voice), Audio Player, Markdown & Note Previews
### Items: IMP-101 to IMP-200

---

### IMP-101: Markdown Link Custom Scheme Navigation Guard
- **Category:** Security / Privacy
- **Current behaviour:** In `lib/widgets/markdown_text.dart:165-175`, tapped markdown links trigger external URL launches immediately via `url_launcher`. Malicious or unexpected URL schemes (`javascript:`, `intent:`, `smsto:`) pasted into notes could invoke system handlers without user awareness.
- **Proposed improvement:** Validate URL schemes against a strict whitelist (`https:`, `http:`, `notekar:`, `mailto:`, `tel:`). For any non-HTTP link or external domain change, present an Apple HIG confirmation sheet: `"Open External Link? [URL] [Cancel] [Open]"`.
- **User benefit:** Prevents accidental navigation or execution of unverified intent schemes from imported or shared markdown notes.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/widgets/markdown_text.dart:170`
- **Verification:** Tap a link formatted as `[Test](intent://...)`; verify safe prompt intercepts the action and gives cancel option.

---

### IMP-102: Timeline Voice Player Pill Ballistic Scrubbing Haptic Feedback
- **Category:** Tactile Feedback / Audio
- **Current behaviour:** In `lib/widgets/timeline_voice_player_pill.dart:95-130`, dragging across the waveform scrubs through the voice memo, but `_lastHapticScrubIndex` only fires during discrete 10% buckets. Fast scrubbing produces an erratic, clumped vibration pattern.
- **Proposed improvement:** Implement ballistic scrub detents that fire `HapticFeedback.selectionClick()` dynamically based on bar index boundaries (`10 bars = 10 crisp mechanical notches`), throttled to minimum 40ms intervals.
- **User benefit:** Scrubbing feels like turning a finely machined physical rotary wheel on high-end audio equipment.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:115`
- **Verification:** Drag thumb slowly across waveform; feel exactly 10 distinct, evenly spaced clicks corresponding to each bar.

---

### IMP-103: Lightbox Pinch-to-Zoom Maximum Scale Bound Clamping
- **Category:** Visual Polish / UX
- **Current behaviour:** In `lib/widgets/photo_lightbox_dialog.dart:82-90`, `TransformationController` allows zooming in up to default matrix bounds without an upper dampener, occasionally allowing 20x extreme zoom where pixels turn into blurry abstract blocks.
- **Proposed improvement:** Clamp `maxScale` to `4.5x` with an elastic resistance curve between 4.5x and 5.0x that smoothly bounces back to 4.5x on touch release.
- **User benefit:** Clean, crisp image inspection that prevents disorienting hyper-zooms.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:140`
- **Verification:** Pinch image to extreme zoom; verify it smoothly springs back to 4.5x upon finger release.

---

### IMP-104: Swipeable Card Bed Threshold Vibration Escalation
- **Category:** Tactile Feedback / Micro-Interaction
- **Current behaviour:** In `lib/widgets/swipeable_card_bed.dart:98-120`, when dragging a timeline card horizontally, passing the delete threshold fires a single `selectionClick()`. If the user drags further into the destructive zone, no additional tactile cue occurs.
- **Proposed improvement:** Provide a two-stage tactile escalation: `lightImpact()` when the action label reveals (35% swipe), and `mediumImpact()` with a color deepening pulse when the full dismiss threshold is unlocked (75% swipe).
- **User benefit:** Intuitive physical awareness of the exact point where releasing will trigger the delete or edit action.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/swipeable_card_bed.dart:105`
- **Verification:** Swipe a moment card slowly to the left; feel the distinct light tick at 35% followed by a firmer confirmation click at 75%.

---

### IMP-105: Multi-Image Attachment Carousel Dot Pagination Indicator
- **Category:** Visual Polish / Discoverability
- **Current behaviour:** In `lib/widgets/timeline_media_attachment_card.dart:45-80`, when a moment contains 3-5 images, they render in a horizontal scrolling thumbnail row with no pagination dots. Users often don't realize more photos exist off-screen.
- **Proposed improvement:** Add a miniature segmented pill pagination indicator (e.g. `[• • •]`) aligned to the bottom right of the photo strip.
- **User benefit:** Instant visual clarity on how many photos are attached to the moment.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_media_attachment_card.dart:65`
- **Verification:** Attach 4 photos to a note; view timeline card; confirm active dot pagination updates smoothly as thumbnails scroll.

---

### IMP-106: Audio Service Background Audio Focus Interruption Recovery
- **Category:** Reliability / Audio
- **Current behaviour:** In `lib/services/audio_service.dart:85-110`, if an incoming phone call or GPS navigation instruction interrupts voice memo playback, the audio stops abruptly and does not resume or update its play/pause UI state cleanly.
- **Proposed improvement:** Register an `OnAudioFocusChangeListener` in `MainActivity.kt`; when focus is ducked or temporarily lost, pause playback cleanly and broadcast state back through the method channel.
- **User benefit:** No audio collisions with telephone calls, GPS alerts, or voice assistants.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:52`
- **Verification:** Play voice note in NoteKar; simulate incoming phone call; verify audio pauses immediately and player button updates to Play icon.

---

### IMP-107: Big Note Fullscreen Canvas Word Counter Tabular Figures
- **Category:** Typography / Polish
- **Current behaviour:** In `lib/dialogs/big_note_dialog.dart:140-160`, the header displays `'1,240 words • 6 min read'`. When typing rapidly, proportional font rendering causes the adjacent reading time text to jitter horizontally.
- **Proposed improvement:** Apply `FontFeature.tabularFigures()` to the word counter text style.
- **User benefit:** Calm, rock-solid counter metrics that update smoothly without vibrating adjacent copy.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:152`
- **Verification:** Type quickly in Big Note; observe word count incrementing while adjacent reading time label stays perfectly stable.

---

### IMP-108: Smart Trim Sheet Duration Delta Visualization
- **Category:** Visual Polish / UX
- **Current behaviour:** In `lib/dialogs/smart_trim_sheet.dart:60-75`, `SmartTrimSheet` shows the new proposed duration, but does not clearly highlight how many hours or minutes are being trimmed off the original session.
- **Proposed improvement:** Add a prominent negative delta badge: `"-1h 45m trimmed"` in soft orange (`p.orange.withValues(alpha: 0.15)`) beside the new duration.
- **User benefit:** Transparent feedback on exactly how much accidental overtime is being removed.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/smart_trim_sheet.dart:68`
- **Verification:** Open Smart Trim for a 5-hour session; trim to 3 hours; verify `"-2h 00m trimmed"` badge displays clearly.

---

### IMP-109: Merge Entries Combined Note Preview Diff Highlighting
- **Category:** Functional Intelligence / UX
- **Current behaviour:** In `lib/dialogs/merge_entries_sheet.dart:75-100`, merging two single moments combines their text notes into a single textfield without indicating which text came from Moment A vs Moment B.
- **Proposed improvement:** Render a subtle preview split showing: `"[Moment A Note] ↵ [Moment B Note]"` with subtle pill tags marking the source timestamps.
- **User benefit:** Users can verify the chronological sequence of their notes before permanently merging them.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/merge_entries_sheet.dart:88`
- **Verification:** Select 2 moments with notes; tap merge; observe labeled preview showing how the combined note will be structured.

---

### IMP-110: Note Preview Sheet Previous/Next Swiping Page Transitions
- **Category:** User Flows / Gestures
- **Current behaviour:** In `lib/dialogs/note_preview_sheet.dart:55-80`, stepping between notes requires tapping the chevron icon buttons in the header. Horizontal swiping on the note body does nothing.
- **Proposed improvement:** Wrap the note body in a `PageView.builder` backed by `widget.items`, allowing natural horizontal page-swiping between chronological notes.
- **User benefit:** Reading through a day's journal or meeting notes feels like turning pages in a sleek personal book.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_preview_sheet.dart:120`
- **Verification:** Open note preview; swipe left on the card; verify it glides smoothly to the next note of the day.

---

### IMP-111: Voice Memo Playback Speed Toggle (1.0x / 1.5x / 2.0x)
- **Category:** Functional Intelligence / Audio
- **Current behaviour:** In `lib/widgets/timeline_voice_player_pill.dart:150-200`, voice notes only play at standard 1.0x speed. Long 5-10 minute voice memos require substantial listening time.
- **Proposed improvement:** Add an Apple Voice Memos-style speed badge `[1.0x]` that cycles to `1.5x` and `2.0x` on tap, updating `MediaPlayer.setPlaybackParams()`.
- **User benefit:** Invaluable time-saving convenience for reviewing long audio memos and meeting recordings.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:175`
- **Verification:** Tap speed pill while playing voice note; hear playback smoothly accelerate to 1.5x pitch-corrected audio.

---

### IMP-112: Photo Lightbox Double-Tap Zoom to Point
- **Category:** User Flows / Gestures
- **Current behaviour:** In `lib/widgets/photo_lightbox_dialog.dart:90-95`, double-tapping always zooms into the geometric center of the photo rather than the exact coordinate where the user tapped.
- **Proposed improvement:** Use `_doubleTapDetails.localPosition` to compute the matrix scale translation, centering the zoom directly on the tapped feature (e.g. text on a whiteboard or receipt total).
- **User benefit:** Instant, effortless inspection of whiteboard notes and handwritten sketches.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:92`
- **Verification:** Double-tap the top-left corner of an image; confirm zoom centers precisely on the top-left corner.

---

### IMP-113: Timeline Session Card Category Meta Accent Bar Alignment
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_session_card.dart:110-125`, the left vertical accent bar has a width of 3.5dp with square ends, appearing slightly heavy against rounded card corners.
- **Proposed improvement:** Give the vertical indicator pill rounded capsule ends (`BorderRadius.circular(999)`) with a 3.0dp optical width.
- **User benefit:** Refined, harmonious curvature matching the card's continuous squircle boundary.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_session_card.dart:118`
- **Verification:** Inspect session cards on timeline; verify left color indicator has soft rounded pill ends.

---

### IMP-114: Markdown Blockquote Tap-to-Copy Action
- **Category:** Convenience / UX
- **Current behaviour:** In `lib/widgets/markdown_text.dart:36-44`, blockquotes (`> Quote`) render as stylized text, but long-pressing the blockquote has no dedicated copy action.
- **Proposed improvement:** Add a subtle copy icon or long-press context menu on blockquote containers that copies the quoted passage to clipboard with a brief toast confirmation.
- **User benefit:** Quick extraction of quotes, mantras, or saved snippets without tedious text selection handle dragging.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/markdown_text.dart:40`
- **Verification:** Long-press any blockquote in a note preview; verify clipboard gets populated with the quote text.

---

### IMP-115: Timeline Consolidated Card Expanding Accordion Animation
- **Category:** Visual Polish / Micro-Interaction
- **Current behaviour:** In `lib/widgets/timeline_consolidated_card.dart:50-80`, tapping to expand grouped category sessions causes the child cards to appear abruptly.
- **Proposed improvement:** Animate child card revelation using an `AnimatedCrossFade` or `SizeTransition` with `NkCurves.appleEase` over 280ms.
- **User benefit:** Silky smooth accordion expansion that preserves spatial continuity.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_consolidated_card.dart:65`
- **Verification:** Tap a consolidated 3-session category card; observe child sessions slide out fluidly.

---

### IMP-116: Note Dialog Unsaved Changes Dismissal Confirmation Shield
- **Category:** Reliability / Data Safety
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:600-618`, tapping the close button or outside the modal when the user has typed 300 words of notes immediately discards the entire draft without confirmation.
- **Proposed improvement:** If `_controller.text.trim().isNotEmpty` and content has changed from `initialNote`, prompt: `"Discard Unsaved Note? [Keep Editing] [Discard]"` with destructive red button.
- **User benefit:** Saves users from catastrophic accidental loss of deep reflections or meeting notes.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/note_dialog.dart:602`
- **Verification:** Type a paragraph into Note Dialog; tap Close; verify confirmation sheet prevents accidental discard.

---

### IMP-117: Timeline Gap Card "Claim as Sleep" One-Tap Quick Action
- **Category:** Functional Intelligence / UX
- **Current behaviour:** In `lib/widgets/timeline_gap_card.dart:45-90`, an untracked overnight gap (e.g. 23:00 to 07:00) displays a generic "Claim as Rest" button that opens manual entry.
- **Proposed improvement:** If the gap occurred between 21:00 and 09:00 and is >4 hours, provide a dedicated "Claim as Sleep" chip that logs a restful recovery moment in 1 tap.
- **User benefit:** 1-tap ledger reconciliation every morning without entering start and end times.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_gap_card.dart:68`
- **Verification:** Look at overnight gap card in morning; tap "Claim as Sleep"; verify 8-hour sleep session logs instantly.

---

### IMP-118: Hashtag Suggestion Overlay Ranking by Recent Usage Frequency
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/widgets/hashtag_suggestion_overlay.dart:45-80`, typing `#` shows tags in alphabetical order. Frequently used tags are buried if they start with 'W' or 'Z'.
- **Proposed improvement:** Sort suggestions by descending frequency count over the last 30 days (`TagService.instance.getRecentTagFrequencies()`).
- **User benefit:** The user's 3 most frequent tags appear right above the keyboard on the first keystroke.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/hashtag_suggestion_overlay.dart:55`
- **Verification:** Type `#`; confirm most-used tags like `#deepwork` and `#review` appear first in the horizontal strip.

---

### IMP-119: Voice Player Pill Audio Waveform Played/Remaining Dual Coloring
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_voice_player_pill.dart:82-95`, all 10 waveform bars use a single static color tint regardless of current playback progress.
- **Proposed improvement:** Dynamically color bars before the current playhead in high-contrast `p.accent`, and bars ahead of the playhead in subtle `p.text3.withValues(alpha: 0.3)`.
- **User benefit:** Clear, glanceable indication of elapsed vs remaining audio progress.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:88`
- **Verification:** Play a 30s voice memo; observe waveform bars fill with accent color from left to right as audio plays.

---

### IMP-120: Photo Lightbox Share Button Native Intent Integration
- **Category:** Android System Integration / Convenience
- **Current behaviour:** `PhotoLightboxDialog` allows viewing and zooming photos, but has no share button to export or send the image to another app.
- **Proposed improvement:** Add a top-right action button (`Icons.share_rounded`) that shares the resolved image file via Android `FileProvider` and `Share.shareXFiles()`.
- **User benefit:** Share whiteboard photos, receipts, or visual memories directly with colleagues or family in 1 tap.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:180`
- **Verification:** Tap Share icon in lightbox; verify native Android share sheet opens with the selected photo attached.

---

### IMP-121: Markdown Strikethrough Completed Checklist Interactive Toggling
- **Category:** Functional Intelligence / UX
- **Current behaviour:** In `lib/widgets/markdown_text.dart:60-70`, checklists (`- [ ]`) render as static text. Tapping a checkbox does nothing; the user must edit the note to type `x`.
- **Proposed improvement:** Make rendered checklist boxes interactive in note previews: tapping toggles `- [ ]` to `- [x]` in the database with a light tactile click.
- **User benefit:** Turn NoteKar notes into live, functional interactive checklists without entering edit mode.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/markdown_text.dart:65`
- **Verification:** Tap empty checkbox in note preview; verify it ticks, strikes through text, and saves to database immediately.

---

### IMP-122: Multi-Photo Grid 2x2 Thumbnail Masonry Layout
- **Category:** Visual Polish / Layout
- **Current behaviour:** In `lib/widgets/timeline_media_attachment_card.dart:50`, 4 photos display in a long horizontal scrolling ribbon.
- **Proposed improvement:** When exactly 4 photos exist, render a tight 2x2 rounded squircle grid matching Twitter/Telegram photo collages.
- **User benefit:** All 4 photos are immediately visible at a glance without horizontal scrolling.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_media_attachment_card.dart:55`
- **Verification:** Attach 4 photos to a session; view timeline; observe elegant 2x2 photo collage.

---

### IMP-123: Voice Recording Auto-Pause on Low Disk Space Detection
- **Category:** Reliability / Storage Safety
- **Current behaviour:** If device free storage falls below 50MB during audio recording, the OS audio recorder fails silently or creates a corrupted 0-byte file.
- **Proposed improvement:** Check available storage in `MediaStorageService`; if free disk space is <100MB, gracefully finalize the recording and alert the user.
- **User benefit:** Protects device integrity and prevents cryptic hardware recorder crash errors.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/media_storage_service.dart:180`
- **Verification:** Simulate low storage condition; attempt recording; confirm safe warning prevents file corruption.

---

### IMP-124: Timeline Single Tile Moment Type Glyph Optical Alignment
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_single_tile.dart:97-105`, the moment icon inside the squircle badge is optically 1dp below center due to icon font glyph metrics.
- **Proposed improvement:** Add `Alignment(0.0, -0.15)` inside the container alignment property.
- **User benefit:** Perfectly centered icon glyphs inside squircle badge containers.
- **Implementation effort:** 1
- **User impact:** 2
- **Priority:** P3
- **Implementation location:** `lib/widgets/timeline_single_tile.dart:100`
- **Verification:** Zoom into the single tile icon badge; verify glyph sits at true mathematical and optical center.

---

### IMP-125: Markdown Code Block Monospace Font Size Legibility Boost
- **Category:** Typography / Accessibility
- **Current behaviour:** In `lib/widgets/markdown_text.dart:95-115`, inline code snippets use 12pt font while surrounding body text is 15pt, causing code to look diminutive and strained.
- **Proposed improvement:** Set inline code font size to `0.92x` of surrounding body text (`14.0pt`) with 1.3 line height and subtle rounded background badge.
- **User benefit:** Code snippets, terminal commands, and hex tags are effortlessly readable inline.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/markdown_text.dart:102`
- **Verification:** Inspect a note containing `git commit -m "fix"`; verify code text scales harmoniously with surrounding prose.

---

### IMP-126: Note Preview Sheet Share as Plain Text or Image Card
- **Category:** Convenience / UX
- **Current behaviour:** `NotePreviewSheet` has an Edit button, but no quick export button to share the note formatted as plain text or as a rendered image quote.
- **Proposed improvement:** Add a "Share Note" action in the sheet header offering: (1) Copy Plain Text, (2) Share via Android Share Sheet, (3) Export as Image Card.
- **User benefit:** Effortless sharing of daily journal reflections or meeting summaries with external tools.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_preview_sheet.dart:180`
- **Verification:** Tap Share in Note Preview; choose Share Text; verify native share sheet opens with cleanly formatted markdown.

---

### IMP-127: Big Note Dialog Focus Mode Dimming of Non-Active Paragraphs
- **Category:** Functional Intelligence / Focus
- **Current behaviour:** In `lib/dialogs/big_note_dialog.dart`, all text on screen retains 100% full opacity while typing.
- **Proposed improvement:** Add an optional "Typewriter Focus Mode" icon that gently dims non-active paragraphs to 40% opacity, highlighting only the current active paragraph.
- **User benefit:** Immersive, distraction-free creative writing environment inspired by iA Writer.
- **Implementation effort:** 3
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:210`
- **Verification:** Toggle Typewriter mode in Big Note; observe current paragraph in 100% contrast while others gently recede.

---

### IMP-128: Voice Memo Recording Audio Quality Bitrate Selector
- **Category:** Settings / Audio Optimization
- **Current behaviour:** Audio recording in `MainActivity.kt:180` records at fixed 128kbps AAC. Users recording 2-hour lectures accumulate large files.
- **Proposed improvement:** Add a setting in Capture Settings: `Voice Note Quality: High (128kbps AAC) | Compact Voice (32kbps AAC-HE)`.
- **User benefit:** Reduces voice file storage by 75% for users who take dozens of audio memos daily.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:185`
- **Verification:** Switch to Compact Voice; record 10 seconds; verify file size is under 45KB.

---

### IMP-129: Swipeable Card Bed Accidental Edit Trigger Protection
- **Category:** User Flows / Reliability
- **Current behaviour:** In `lib/widgets/swipeable_card_bed.dart:115`, swiping right by only 45dp triggers the note edit sheet immediately on release.
- **Proposed improvement:** Require at least 70dp displacement and positive velocity before unlocking the edit modal.
- **User benefit:** Prevents accidental opening of edit sheets when scrolling diagonally down the timeline.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/swipeable_card_bed.dart:118`
- **Verification:** Perform slight diagonal swipe right while scrolling; verify note edit sheet does not accidentally pop up.

---

### IMP-130: Timeline Session Card Sub-Second Time Format Option
- **Category:** Personalization / Precision
- **Current behaviour:** Session cards display duration as `1h 24m`. Athletic or sprint intervals cannot view seconds.
- **Proposed improvement:** When `_showSeconds` is enabled in Display settings, format durations under 1 hour as `24m 18s` and over 1 hour as `1h 24m 18s`.
- **User benefit:** High-precision tracking for workouts, pomodoro sprints, and lab procedures.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_session_card.dart:95`
- **Verification:** Enable Show Seconds; view 20-minute session; observe exact `20m 42s` duration.

---

### IMP-131: Photo Lightbox Smooth Pull-Down Drag-to-Dismiss
- **Category:** Visual Polish / Gestures
- **Current behaviour:** In `lib/widgets/photo_lightbox_dialog.dart:89`, pulling down on an image translates it, but the background opacity does not fade proportionally.
- **Proposed improvement:** Dynamically tie background barrier opacity to vertical drag delta (`alpha = (1.0 - (dragY / 300.0).clamp(0.0, 1.0)) * 0.88`).
- **User benefit:** Fluid, modern image dismiss gesture matching Apple Photos and Instagram.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:95`
- **Verification:** Drag photo downward; observe background darkness fade smoothly to transparent as photo tracks the finger.

---

### IMP-132: Markdown Bullet List Nested Indentation Visual Hierarchy
- **Category:** Typography / Polish
- **Current behaviour:** In `lib/widgets/markdown_text.dart:140-155`, sub-bullets with 2 or 4 leading spaces render with the same indentation offset and bullet glyph as top-level bullets.
- **Proposed improvement:** Support 2-level nested bullets: indent sub-bullets by 20dp and render an open ring glyph (`○`) instead of a solid disc (`●`).
- **User benefit:** Clean, readable hierarchical outlining for structured meeting notes and research outlines.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/markdown_text.dart:145`
- **Verification:** Create note with sub-bullet list; verify sub-items indent cleanly with hollow ring bullet markers.

---

### IMP-133: Voice Memo Player Scrubbing Time Bubble Tooltip
- **Category:** Visual Polish / Audio
- **Current behaviour:** During scrubbing in `lib/widgets/timeline_voice_player_pill.dart:110`, the elapsed counter updates in place, but there is no floating time bubble directly above the user's thumb.
- **Proposed improvement:** Display a small floating pill badge (`0:42`) directly above the active thumb touch point during drag scrubbing.
- **User benefit:** The user's thumb does not obstruct the timestamp they are scrubbing toward.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:125`
- **Verification:** Scrub voice memo; observe floating time badge hovering 24dp above fingertip.

---

### IMP-134: Timeline Gap Card Automatic "Claim as Lunch / Break" Detection
- **Category:** Functional Intelligence
- **Current behaviour:** Midday gaps between 12:00 and 14:00 (e.g. 12:30 to 13:15) show generic "Untracked Gap".
- **Proposed improvement:** Detect midday 30-90 minute gaps and suggest a 1-tap chip: `[Claim as Lunch / Break ☕]`.
- **User benefit:** Frictionless midday life ledger reconciliation with a single touch.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_gap_card.dart:75`
- **Verification:** Check timeline at 14:00 with untracked lunch hour; see contextual "Claim as Lunch" chip.

---

### IMP-135: Photo Thumbnail Image Compression on Staged Camera Capture
- **Category:** Performance / Storage
- **Current behaviour:** Taking a photo via camera in `NoteDialog` captures at maximum raw resolution, creating 6-8MB image files on 108MP camera sensors.
- **Proposed improvement:** Resize captured photos to max 1920x1080 with 85% WebP or JPEG compression in `MediaStorageService.saveImage()`.
- **User benefit:** Reduces photo storage by 80% while preserving crystal-clear whiteboard and text legibility.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/services/media_storage_service.dart:120`
- **Verification:** Capture photo with high-res camera; confirm saved file in `notekar_media/images` is under 600KB.

---

### IMP-136: Smart Trim Slider Snapping to Round 15-Minute Marks
- **Category:** UX / Precision
- **Current behaviour:** In `lib/dialogs/smart_trim_sheet.dart:85-110`, adjusting the end time via custom time picker requires scrolling wheel drums.
- **Proposed improvement:** Add quick 1-tap shortcut pills: `[-30 mins]`, `[-1 hour]`, `[-2 hours]`, and `[Snap to 15m]`.
- **User benefit:** Trim accidental overtime in 1 second without spinning time picker wheels.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/smart_trim_sheet.dart:95`
- **Verification:** Open Smart Trim; tap `[-1 hour]` chip; verify session duration immediately reduces by 60 minutes.

---

### IMP-137: Voice Memo Playback Audio Output Device Routing (Speaker vs Earpiece)
- **Category:** Privacy / Convenience
- **Current behaviour:** Voice notes always play through the loud bottom loudspeaker. In a public train or office, private voice memos are overheard by bystanders.
- **Proposed improvement:** Add a speaker/earpiece toggle button on `TimelineVoicePlayerPill`; automatically route to handset earpiece when proximity sensor detects phone held to ear.
- **User benefit:** Discrete, private listening to confidential voice notes in public settings.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:210`
- **Verification:** Lift phone to ear while playing voice memo; verify audio routes seamlessly to private earpiece speaker.

---

### IMP-138: Big Note Dialog Markdown Cheat Sheet Slide-Over
- **Category:** Discoverability / Education
- **Current behaviour:** In `lib/dialogs/big_note_dialog.dart:180`, users unfamiliar with markdown syntax have no quick way to look up how to format tables, links, or headers.
- **Proposed improvement:** Add a subtle `?` button that slides in a compact 1-page Markdown syntax quick reference drawer.
- **User benefit:** Empowers novice users to take advantage of rich formatting without leaving the app to search online.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:195`
- **Verification:** Tap `?` in Big Note; verify slide-over sheet displays markdown formatting examples.

---

### IMP-139: Merge Entries Automatic Chronological Re-Ordering
- **Category:** Reliability / Data Integrity
- **Current behaviour:** In `lib/dialogs/merge_entries_sheet.dart:87-94`, if a user selects Moment B and Moment A in reverse order, `_startMoment` and `_endMoment` swap correctly, but the title banner does not clarify that the earlier timestamp was selected as Start.
- **Proposed improvement:** Clearly label the top card with a prominent green badge `"Start: 09:30 AM"` and bottom card with `"End: 11:45 AM"`.
- **User benefit:** Eliminates user doubt regarding which moment serves as the beginning of the merged session.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/merge_entries_sheet.dart:90`
- **Verification:** Select 2 moments in reverse order; verify sheet header explicitly labels which timestamp is Start vs End.

---

### IMP-140: Timeline Media Attachment Long-Press Context Menu
- **Category:** User Flows / Convenience
- **Current behaviour:** In `lib/widgets/timeline_media_attachment_card.dart:70-95`, long-pressing a photo thumbnail does nothing; tapping opens full lightbox.
- **Proposed improvement:** Long-pressing a photo thumbnail triggers an Apple-style Haptic Context Menu offering: `[View Fullscreen]`, `[Share Image]`, `[Save to Gallery]`, `[Remove from Note]`.
- **User benefit:** Fast management and export of media assets without full-screen navigation.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_media_attachment_card.dart:80`
- **Verification:** Long-press photo thumbnail; verify Cupertino context menu opens with action options.

---

### IMP-141: Markdown Emoji Shortcode Auto-Expansion (`:fire:`, `:star:`)
- **Category:** Delight / Productivity
- **Current behaviour:** Typing `:fire:` in note editing stays as literal colon text.
- **Proposed improvement:** In `MarkdownTextEditingController`, auto-expand common GitHub/Slack emoji shortcodes (`:rocket:`, `:fire:`, `:check:`, `:star:`, `:heart:`) upon space or return.
- **User benefit:** Rapid expressive note-taking matching desktop messaging ergonomics.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/utils/markdown_text_editing_controller.dart:65`
- **Verification:** Type `:rocket:` followed by space; verify it instantly converts to 🚀.

---

### IMP-142: Timeline Session Card Ongoing Duration Live Stopwatch Pulse
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_session_card.dart:106`, if a session card is ongoing on the timeline, its duration text updates statically every second without visual feedback.
- **Proposed improvement:** Add a subtle green breathing dot `🟢 Live` that pulses gently on a 1-second sine wave beside the duration counter.
- **User benefit:** Immediately communicates that the session is currently active and accumulating time in real time.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_session_card.dart:112`
- **Verification:** View ongoing session in history timeline; confirm glowing breathing dot beside running time.

---

### IMP-143: Note Dialog Hashtag Autocomplete Dropdown Keyboard Dismissal Safety
- **Category:** UX / Polish
- **Current behaviour:** In `lib/widgets/hashtag_suggestion_overlay.dart:60`, tapping a suggested hashtag inserts the tag, but can occasionally trigger soft keyboard redraw flicker.
- **Proposed improvement:** Preserve keyboard focus state and caret offset without rebuilding the entire textfield.
- **User benefit:** Seamless typing flow without keyboard flickering or caret jumping to line start.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/hashtag_suggestion_overlay.dart:72`
- **Verification:** Type `#d`; tap `#deepwork` suggestion; verify tag inserts smoothly with keyboard staying rock steady.

---

### IMP-144: Voice Player Pill Dynamic Waveform Sample Extraction
- **Category:** Visual Polish / Audio
- **Current behaviour:** In `lib/widgets/timeline_voice_player_pill.dart:83`, waveform heights use static hardcoded values `_kWaveformHeights`. All voice memos look identical regardless of audio content.
- **Proposed improvement:** When saving a voice memo, compute 10 normalized RMS amplitude points from the recorded file in `AudioService` and store them in `Moment.voiceWaveform`.
- **User benefit:** Authentic visual identity for each voice note: silent pauses and vocal spikes are physically visible.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/services/audio_service.dart:145`
- **Verification:** Record a note with quiet whispers then loud talking; confirm waveform accurately reflects the dynamic amplitude shape.

---

### IMP-145: Photo Lightbox Gallery Delete Single Photo from Multi-Set
- **Category:** User Flows / Media Management
- **Current behaviour:** In `PhotoLightboxDialog`, if a moment has 5 photos and photo #3 was blurry, there is no way to delete just photo #3 without clearing all photos.
- **Proposed improvement:** Add a trash icon button in the lightbox header: `"Remove this photo from note? [Cancel] [Remove]"`.
- **User benefit:** Precision photo curation without having to re-take or re-import the entire photo set.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:190`
- **Verification:** Open photo 2 of 4 in lightbox; tap Delete; confirm only photo 2 is removed while photos 1, 3, and 4 remain.

---

### IMP-146: Big Note Writing Canvas Auto-Indent on New Line After List
- **Category:** Productivity / Typography
- **Current behaviour:** In `lib/dialogs/big_note_dialog.dart`, pressing Enter on a bulleted line (`- Item`) drops down to a blank flush-left line.
- **Proposed improvement:** Detect line start: if the previous line starts with `- ` or `* `, automatically insert `- ` on the new line; pressing Enter on an empty `- ` removes the bullet.
- **User benefit:** Frictionless list creation matching standard Markdown editor standards (Obsidian, Notion).
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/utils/markdown_text_editing_controller.dart:95`
- **Verification:** Type `- First item` and hit Enter; verify new line automatically begins with `- `.

---

### IMP-147: Timeline Gap Card Minimum Duration Filter
- **Category:** Settings / Visual Polish
- **Current behaviour:** In `lib/dialogs/history_dialog.dart:173`, enabling "Show Gap Cards" displays every single 2-minute or 5-minute untracked gap between sessions, cluttering the timeline with dozens of tiny cards.
- **Proposed improvement:** Add a setting `Minimum Gap Card Duration: 15m | 30m | 1h | 2h` (default 30m).
- **User benefit:** Focuses attention on meaningful untracked intervals while ignoring negligible transition breaks.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/history_dialog.dart:175`
- **Verification:** Set minimum gap to 30m; verify 5-minute pauses between meetings do not generate distracting gap cards.

---

### IMP-148: Markdown Text Selection Custom Cupertino Handle Styling
- **Category:** Visual Polish / OS Integration
- **Current behaviour:** Selecting text in `MarkdownText` uses standard Android Material teardrop selection handles with theme-inconsistent purple or teal tints.
- **Proposed improvement:** Configure `CupertinoDesktopTextSelectionControls` and `SelectionArea` with `selectionColor: p.accent.withValues(alpha: 0.35)` and `p.accent` cursor.
- **User benefit:** Cohesive, luxury Apple HIG text selection styling across all rendered note cards.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/markdown_text.dart:22`
- **Verification:** Long-press text in note preview; observe sleek pill-shaped selection handles tinted in brand accent.

---

### IMP-149: Voice Memo Scrubbing Reverse Seek 15-Second Skip Buttons
- **Category:** Audio / Convenience
- **Current behaviour:** On long voice memos, precision seeking by thumb drag can be difficult on small screens.
- **Proposed improvement:** Add quick 10-second skip back (`-10s`) and skip forward (`+10s`) buttons in `NotePreviewSheet` voice memo player.
- **User benefit:** Effortless scrubbing back to re-listen to an important phrase or action item.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:165`
- **Verification:** Tap `-10s` during voice memo playback; verify playhead jumps backward by exactly 10 seconds.

---

### IMP-150: Timeline Consolidated Card Daily Category Total Duration Badge
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/widgets/timeline_consolidated_card.dart:45`, grouped cards display `"3 Sessions"` but omit the cumulative duration sum in collapsed mode.
- **Proposed improvement:** Display both: `"3 Sessions • 4h 15m total"` in tabular figures with subtle category color dot.
- **User benefit:** Instant high-level glance at daily category investment without expanding the card.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_consolidated_card.dart:48`
- **Verification:** Collapse 3 work sessions; verify card header reads `3 Sessions • 4h 15m`.

---

### IMP-151: Staged Media Attachment Reordering Drag Handles
- **Category:** User Flows / Media
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:840-880`, staged photos appear in the order they were picked. Users cannot re-order which photo appears as the primary cover thumbnail.
- **Proposed improvement:** Allow long-pressing and dragging photo thumbnails in the staged tray to reorder them prior to saving.
- **User benefit:** Control over which photo serves as the representative cover image on the timeline.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/note_dialog.dart:850`
- **Verification:** Drag photo 3 to first position in note composer; verify it becomes cover image after saving.

---

### IMP-152: Big Note Title Header Editing Capability
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/dialogs/big_note_dialog.dart:280-320`, notes have body text only; the title defaults to `"Plus Note"` or category name.
- **Proposed improvement:** Add an optional dedicated Title field above the body in `BigNoteDialog` that persists as an `H1` markdown header (`# Title`).
- **User benefit:** Proper structured titling for long articles, project briefs, and executive memos.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:290`
- **Verification:** Type a title in Big Note; confirm it saves as `# Title` followed by body content.

---

### IMP-153: Audio Recording Microphone Permission Denial Explanatory Dialog
- **Category:** Permissions / UX
- **Current behaviour:** If a user denies microphone permission, tapping the mic icon does nothing or fails silently with a console log.
- **Proposed improvement:** Display an informative dialog explaining why microphone access is required for sovereign voice notes, with a direct `"Open App Settings"` button.
- **User benefit:** Eliminates user confusion when voice recording fails due to system permission state.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/note_dialog.dart:225`
- **Verification:** Revoke microphone permission; tap mic button; verify explanatory sheet directs to Android settings.

---

### IMP-154: Markdown Table Rendering Support
- **Category:** Visual Polish / Typography
- **Current behaviour:** Markdown tables (`| Col 1 | Col 2 |`) render as raw monospace text with pipes visible.
- **Proposed improvement:** Parse markdown table syntax into a clean, horizontally scrollable data table with hairline borders and alternating row tints.
- **User benefit:** Professional tabular data viewing inside meeting notes and log reflections.
- **Implementation effort:** 3
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/markdown_text.dart:180`
- **Verification:** View note with markdown table; verify clean styled grid with rounded corners and cell padding.

---

### IMP-155: Swipeable Card Bed Dynamic Color Bed Depth
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/swipeable_card_bed.dart:130-150`, the color bed beneath the card is flat solid red or blue.
- **Proposed improvement:** Add a subtle inner shadow along the sliding card edge to create authentic physical depth of the top card sliding over the underlying bed.
- **User benefit:** Exceptional physical realism matching iOS Mail and Apple Notes swipe actions.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/swipeable_card_bed.dart:135`
- **Verification:** Swipe card slowly; observe subtle 3D edge shadow tracking the trailing edge of the moving card.

---

### IMP-156: Timeline Session Card Goal Link Tag Touch Ripple
- **Category:** Micro-Interaction
- **Current behaviour:** In `lib/widgets/timeline_session_card.dart:130-160`, the linked goal chip has no `PressableScale` or ink touch feedback when tapped to view goal details.
- **Proposed improvement:** Wrap the goal chip in `PressableScale` with a light selection click haptic.
- **User benefit:** Clear tactile feedback confirming the chip is interactive.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_session_card.dart:140`
- **Verification:** Tap goal tag on session card; feel subtle micro-spring compression.

---

### IMP-157: Voice Memo Temporary Recording Cache Cleanup on Discard
- **Category:** Reliability / Storage Management
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:260-270`, cancelling a voice recording calls `AudioService.instance.cancelRecording()`, but if the app crashes before cancel completes, orphan `.m4a` files can remain in temp cache.
- **Proposed improvement:** Run an automated orphan file cleanup during `MediaStorageService.initialize()` that removes unlinked temp recordings older than 24 hours.
- **User benefit:** Prevents invisible storage bloat over months of usage.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/media_storage_service.dart:210`
- **Verification:** Leave mock abandoned audio file in temp cache; restart app; verify orphan file is safely pruned.

---

### IMP-158: Photo Lightbox Image Save to Android MediaStore Gallery
- **Category:** Android System Integration / Convenience
- **Current behaviour:** Photos taken in NoteKar are stored in internal sandboxed storage. Users cannot easily save a copy to the Android device's public Photos/Gallery app.
- **Proposed improvement:** Add a "Save to Photos" button in the lightbox that copies the image to `MediaStore.Images.Media.EXTERNAL_CONTENT_URI` with a toast: `"Saved to Gallery"`.
- **User benefit:** Effortless access to photos taken inside NoteKar from external photo editors and cloud backups.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:310`
- **Verification:** Tap 'Save to Photos' in Lightbox; open Google Photos / Samsung Gallery; verify photo appears in gallery.

---

### IMP-159: Note Dialog Character Count Warning Color Ramp
- **Category:** Visual Polish / UX
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:505`, the character counter stays neutral until the last 20 characters, then snaps to stark red.
- **Proposed improvement:** Introduce a gentle amber warning state when 50 characters remain (`p.orange`), transitioning smoothly to red when 15 characters remain.
- **User benefit:** Early, graceful visual warning before hitting max note length bounds.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/note_dialog.dart:515`
- **Verification:** Type note up to 450/500 characters; observe counter shift from neutral -> amber -> red.

---

### IMP-160: Smart Trim Sheet Visual Hour-Block Breakdown
- **Category:** Visual Polish
- **Current behaviour:** `SmartTrimSheet` displays a textual list of end times.
- **Proposed improvement:** Render a miniature horizontal timeline bar showing the original session block with the trimmed segment visually shaded with diagonal hazard stripes.
- **User benefit:** Clear, intuitive spatial understanding of the time slice being trimmed.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/smart_trim_sheet.dart:120`
- **Verification:** Open Smart Trim; see visual segmented bar showing active vs trimmed hours.

---

### IMP-161: Voice Memo Playback Pause Resume Scrub State Synchronization
- **Category:** Reliability / Audio
- **Current behaviour:** If audio is scrubbing while paused, resuming sometimes starts from the pre-scrub position if the native player position hasn't finished seeking.
- **Proposed improvement:** Await `seekTo` completion callback before triggering native audio resume.
- **User benefit:** Reliable, glitch-free audio playback resume at the exact intended scrub position.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/services/audio_service.dart:125`
- **Verification:** Pause voice memo, scrub to 0:45, tap Play; verify audio immediately begins from 0:45 without jumping back.

---

### IMP-162: Big Note Zen Mode Distraction-Free Fullscreen Toggle
- **Category:** User Flows / Focus
- **Current behaviour:** In `BigNoteDialog`, top app bar, word counter, and close button are always visible on screen while typing.
- **Proposed improvement:** Automatically fade out header controls after 3 seconds of continuous typing; fade them back in immediately when typing stops or on pointer hover.
- **User benefit:** Pure, immersive digital paper experience for deep reflective writing.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:230`
- **Verification:** Type continuously in Big Note; observe chrome controls smoothly disappear, leaving only text canvas.

---

### IMP-163: Timeline Media Attachment Shimmer Skeleton on Initial Load
- **Category:** Visual Polish / Performance
- **Current behaviour:** While high-resolution image thumbnails are decoded from disk, empty grey boxes appear briefly on the timeline before the photo renders.
- **Proposed improvement:** Add a subtle, gentle shimmer gradient skeleton over thumbnail containers during disk read.
- **User benefit:** Eliminates jarring image pop-in during fast timeline scrolling.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_media_attachment_card.dart:95`
- **Verification:** Scroll quickly through timeline with 20 photos; observe smooth shimmer skeletons resolving cleanly into images.

---

### IMP-164: Merge Entries Smart Category Deduction
- **Category:** Functional Intelligence
- **Current behaviour:** In `lib/dialogs/merge_entries_sheet.dart:98`, `_selectedCategory` defaults to `Moment A`'s category or 'Work'.
- **Proposed improvement:** If Moment B has a category and Moment A does not, automatically select Moment B's category; if both have different categories, display both as selectable quick chips.
- **User benefit:** Intelligent default selection that reduces cognitive effort during entry merges.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/dialogs/merge_entries_sheet.dart:98`
- **Verification:** Merge unclassified moment with 'Deep Focus' moment; confirm 'Deep Focus' is automatically chosen.

---

### IMP-165: Note Preview Sheet Fullscreen Pinch-to-Dismiss Gesture
- **Category:** Gestures / UX
- **Current behaviour:** In `NotePreviewSheet`, pinching inward does nothing.
- **Proposed improvement:** Support pinch-to-dismiss gesture: pinching fingers together smoothly shrinks and closes the preview sheet back into the origin card.
- **User benefit:** Tactile, playful gesture navigation matching modern iPad and Android foldable UX.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P3
- **Implementation location:** `lib/dialogs/note_preview_sheet.dart:140`
- **Verification:** Pinch inward on note preview card; observe sheet smoothly scale down and dismiss.

---

### IMP-166: Voice Memo Lock Screen Media Controls Integration
- **Category:** Android System Integration / Audio
- **Current behaviour:** Playing a long 15-minute voice note in NoteKar does not show playback controls on the Android lock screen or notification media player.
- **Proposed improvement:** Attach `MediaSessionCompat` during audio playback, allowing users to pause, seek, and scrub voice memos directly from the Android lock screen.
- **User benefit:** Control audio memo playback while walking or commuting without unlocking the phone.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:240`
- **Verification:** Play voice note, lock device; verify lock screen media player displays title, progress bar, and play/pause controls.

---

### IMP-167: Markdown Code Block Copy Button Micro-Feedback
- **Category:** Visual Polish / Convenience
- **Current behaviour:** Multi-line code blocks in notes have no copy button.
- **Proposed improvement:** Add a neat Apple-style "Copy" icon badge in the upper right corner of code blocks that flips to a green checkmark `✓ Copied` upon tap.
- **User benefit:** 1-tap copying of terminal commands, code snippets, or API keys stored in notes.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/markdown_text.dart:110`
- **Verification:** Tap copy button on code block; observe instant checkmark confirmation and verify text in clipboard.

---

### IMP-168: Timeline Single Tile God Mode Golden Glow Refinement
- **Category:** Delight / Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_single_tile.dart:61-65`, God Mode moments have a custom title, but their visual styling is otherwise similar to standard moments.
- **Proposed improvement:** Add a subtle hairline border with a warm golden amber gradient (`#FFD700` to `#FFA000`) and soft ambient aura for sovereign unlock moments.
- **User benefit:** Distinct celebratory aesthetic rewarding users for unlocking God Mode access.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_single_tile.dart:120`
- **Verification:** View God Mode unlocked moment on timeline; observe radiant golden hairline border.

---

### IMP-169: Note Dialog Voice Recording Pause & Resume Capability
- **Category:** Audio / Functional
- **Current behaviour:** In `lib/dialogs/note_dialog.dart:223-255`, recording audio can only be stopped or cancelled. Users cannot pause mid-thought and resume recording into the same audio file.
- **Proposed improvement:** Add a Pause/Resume button to the recording bar utilizing Android `MediaRecorder.pause()` and `resume()`.
- **User benefit:** Record thoughtful multi-part voice notes without creating fragmented multiple audio files.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_dialog.dart:235`
- **Verification:** Tap Pause during voice recording; think for 5 seconds; tap Resume; verify audio merges seamlessly into single file.

---

### IMP-170: Photo Lightbox Double-Tap Zoom Resistance Bounds
- **Category:** Gestures / Polish
- **Current behaviour:** Double-tapping to zoom toggles between 1.0x and 3.0x instantly. If double-tapped while already zoomed, it resets abruptly to 1.0x without easing.
- **Proposed improvement:** Animate the zoom reset smoothly over 220ms using `NkTokens.curves.appleEase`.
- **User benefit:** Calm, photographic visual transition that never jars the user's eyes.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:115`
- **Verification:** Double tap zoomed image; watch image smoothly zoom out back to resting frame.

---

### IMP-171: Smart Trim Auto-Suggestion Based on Historical Category Norms
- **Category:** Functional Intelligence
- **Current behaviour:** `SmartTrimSheet` suggests default durations (e.g. 1h, 2h, 3h) regardless of the category.
- **Proposed improvement:** Analyze the user's historical average duration for that category (e.g. Work μ = 2h 15m, Workout μ = 45m) and highlight the historical average as a recommended trim option: `"(Usual: 45m)"`.
- **User benefit:** Contextually intelligent trim suggestions that match personal daily habits.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/smart_trim_sheet.dart:80`
- **Verification:** Leave Workout session running for 4 hours; open Smart Trim; verify 45m is highlighted with "(Usual: 45m)".

---

### IMP-172: Timeline Single Tile Note Text Max Lines Clamp with "Read More" Detent
- **Category:** Visual Polish / Layout
- **Current behaviour:** In `lib/widgets/timeline_single_tile.dart:130-150`, extremely long notes (1,000 words) render in full on the timeline card, creating a massive 2,000dp tall card that takes 6 swipes to scroll past.
- **Proposed improvement:** Clamp note previews on the timeline to a maximum of 4 lines with a subtle gradient fade and `"...more"` expander link.
- **User benefit:** Keeps the timeline clean, compact, and scannable without giant disruptive text blocks.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_single_tile.dart:135`
- **Verification:** Log a 500-word note; verify timeline card neatly clamps to 4 lines with clean "more" trigger.

---

### IMP-173: Voice Memo Waveform Scrubbing Audio Scrub Previews
- **Category:** Audio / Delight
- **Current behaviour:** Scrubbing across a voice memo is silent until finger release.
- **Proposed improvement:** Play micro-sound ticks (`15ms audio grains`) during scrubbing to audibly preview the voice under the playhead, similar to professional sound editing software.
- **User benefit:** Audio scrub scrubbing enables users to pinpoint exact words or sound bites by ear.
- **Implementation effort:** 3
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:260`
- **Verification:** Drag thumb across waveform; hear subtle audio grain ticks previewing words under playhead.

---

### IMP-174: Markdown Ordered List Counter Auto-Increment
- **Category:** Productivity / Typography
- **Current behaviour:** Typing `1. Item` in note dialog and pressing enter requires manually typing `2. ` on the next line.
- **Proposed improvement:** Automatically detect ordered list prefix `(\d+)\.\s` and auto-insert the incremented number on newline (`2. `, `3. `).
- **User benefit:** Smooth, natural numbered list creation with zero manual counter bookkeeping.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/utils/markdown_text_editing_controller.dart:105`
- **Verification:** Type `1. Step one` and press Enter; verify `2. ` is automatically inserted.

---

### IMP-175: Big Note Dialog Markdown Image Preview Rendering
- **Category:** Visual Polish / Media
- **Current behaviour:** In `BigNoteDialog`, attached images only show in a compact bottom strip; markdown image tags `![Alt](path)` are rendered as raw text.
- **Proposed improvement:** Render markdown image syntax directly inline within the rendered preview tab with rounded squircle borders.
- **User benefit:** True WYSIWYG rich media document composition for long-form retrospective logs.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:340`
- **Verification:** Switch to preview tab in Big Note; confirm inline photos render with high-res styling.

---

### IMP-176: Timeline Session Card End Time Editing Shortcut
- **Category:** User Flows / Convenience
- **Current behaviour:** To edit the end time of an already completed session, users must open Note Preview -> Edit -> Manual Entry sheet.
- **Proposed improvement:** Tapping the end timestamp on the session card opens a direct time-picker sheet to adjust the end boundary in 1 step.
- **User benefit:** Cuts session boundary correction time from 4 taps down to 1 tap.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_session_card.dart:185`
- **Verification:** Tap the end timestamp ("11:30 AM") on a completed session card; verify direct time picker opens immediately.

---

### IMP-177: Photo Lightbox Multi-Image Swipe Velocity Resistance
- **Category:** Visual Polish / Gestures
- **Current behaviour:** In `PhotoLightboxDialog:80`, swiping between images can feel slippery if the user swipes aggressively, jumping 2 images at once.
- **Proposed improvement:** Set `PageScrollPhysics` to clamp fling page transitions to maximum 1 page per gesture swipe.
- **User benefit:** Deliberate, controlled photo-by-photo browsing without overshooting.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:82`
- **Verification:** Fling violently on photo 1; confirm gallery scrolls strictly to photo 2 and stops.

---

### IMP-178: Merge Entries Retain Media Attachments Across Both Moments
- **Category:** Reliability / Data Safety
- **Current behaviour:** In `MergeEntriesSheet`, if Moment A has a photo and Moment B has a voice note, merging them can occasionally prioritize Moment A's media and drop Moment B's voice note.
- **Proposed improvement:** Seamlessly unify all photos and voice recordings into the merged session (`combinedPhotos = [photoA, photoB].whereNotNull()`, `combinedVoice = [voiceA, voiceB]`).
- **User benefit:** Zero media loss when combining fragmented notes into a unified master session.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P0
- **Implementation location:** `lib/dialogs/merge_entries_sheet.dart:130`
- **Verification:** Merge photo moment with voice moment; verify merged session contains both the photo and the voice note.

---

### IMP-179: Note Dialog Keyboard Accessory Formatting Bar Sticky Positioning
- **Category:** Ergonomics / Keyboard Integration
- **Current behaviour:** On some Android devices with floating keyboards (Gboard floating mode), the formatting bar in `NoteDialog:386-424` can detach from the keyboard top edge.
- **Proposed improvement:** Anchor formatting bar to `MediaQuery.viewInsets.bottom` using a dedicated sticky keyboard-docked layout container.
- **User benefit:** Markdown formatting buttons remain permanently accessible directly above the virtual keyboard.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_dialog.dart:445`
- **Verification:** Switch Gboard to floating mode; verify formatting bar stays pinned directly above the text input.

---

### IMP-180: Voice Memo Player Elapsed Time Countdown Mode Toggle
- **Category:** Functional Intelligence
- **Current behaviour:** `TimelineVoicePlayerPill` always shows elapsed time (`0:15 / 1:30`).
- **Proposed improvement:** Tapping the timestamp toggles between Elapsed Time (`0:15`) and Remaining Time (`-1:15`).
- **User benefit:** Familiar Apple podcast/music ergonomics for reviewing audio notes.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:180`
- **Verification:** Tap time label during playback; see format switch from `0:15` to `-1:15`.

---

### IMP-181: Markdown Text Autolink Phone Numbers and Email Addresses
- **Category:** Functional Intelligence / UX
- **Current behaviour:** In `lib/widgets/markdown_text.dart`, URLs (`https://`) are autolinked, but phone numbers (`+1-555-0199`) and email addresses are rendered as static text.
- **Proposed improvement:** Automatically parse phone numbers and email addresses into clickable links launching `tel:` and `mailto:` intents.
- **User benefit:** 1-tap calling or emailing directly from notes taken during phone conversations.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/markdown_text.dart:160`
- **Verification:** Type "Call +1-800-555-0199" in note; verify phone number highlights as clickable action link.

---

### IMP-182: Timeline Consolidated Card Category Color Strip Accentuation
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_consolidated_card.dart`, the consolidated card uses the default surface color, with minimal color differentiation between categories.
- **Proposed improvement:** Tint the top hairline border and category badge with the specific category's theme color (e.g. emerald for Health, electric blue for Work).
- **User benefit:** Stronger visual categorization when scanning days with multiple project types.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_consolidated_card.dart:55`
- **Verification:** Inspect consolidated card for 'Health'; verify crisp emerald border accent.

---

### IMP-183: Note Preview Sheet Markdown Headers Visual Scale Hierarchy
- **Category:** Typography / Polish
- **Current behaviour:** In `lib/widgets/markdown_text.dart:45`, `H1` (#), `H2` (##), and `H3` (###) use subtle font weight shifts but relatively flat font size differences (18pt vs 16pt).
- **Proposed improvement:** Establish a bold, clear typographical hierarchy: `H1 = 22pt / w800 / tracking -0.4`, `H2 = 18pt / w700 / tracking -0.3`, `H3 = 16pt / w600`.
- **User benefit:** Long documents and structured outlines gain immediate readability and scan value.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/markdown_text.dart:50`
- **Verification:** View note containing `# Title`, `## Section`, and `### Subsection`; observe dramatic, beautiful typographical scaling.

---

### IMP-184: Audio Service Audio Waveform Extraction Background Isolate Offloading
- **Category:** Performance / Smooth Scrolling
- **Current behaviour:** Decoding audio waveforms on the main UI isolate during list build can drop 3-4 frames on mid-tier Android phones.
- **Proposed improvement:** Offload audio file parsing and waveform amplitude extraction to a background worker isolate via `compute()`.
- **User benefit:** Buttery smooth 120fps scrolling through history timelines containing dozens of voice memos.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/services/audio_service.dart:160`
- **Verification:** Scroll rapidly through 50 voice memos; monitor Flutter performance overlay; confirm zero red frame bars.

---

### IMP-185: Photo Lightbox Zoom Lock During Horizontal Gallery Swipes
- **Category:** Gestures / UX
- **Current behaviour:** When zoomed into an image at 2.5x, dragging right to pan the zoomed image can inadvertently trigger a gallery page transition to the next photo.
- **Proposed improvement:** If `scale > 1.05`, lock PageView horizontal paging and reserve all touch gestures exclusively for 2D image panning.
- **User benefit:** Inspect high-resolution photos without accidentally flipping to the next photo in the album.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:130`
- **Verification:** Zoom into photo at 3x; pan left and right; confirm photo pans smoothly without switching to adjacent image.

---

### IMP-186: Timeline Single Tile Moment Duration Since Last Event Badge
- **Category:** Functional Intelligence
- **Current behaviour:** Single moments show absolute timestamp (`10:45 AM`), but don't indicate how long it has been since the previous moment occurred.
- **Proposed improvement:** Add an optional subtle delta metadata tag: `"+2h 15m since last log"`.
- **User benefit:** Instant temporal awareness of intervals between routine check-ins.
- **Implementation effort:** 2
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_single_tile.dart:160`
- **Verification:** Log moment at 10:00 and another at 12:30; observe `+2h 30m` delta tag on second tile.

---

### IMP-187: Smart Trim Sheet Quick "Split Instead of Trim" Option
- **Category:** Functional Intelligence
- **Current behaviour:** `SmartTrimSheet` only offers trimming (discarding) the overtime segment. If the user worked on two different tasks during the 4 hours, trimming discards the second half of work.
- **Proposed improvement:** Add a second primary action: `"Split into 2 Sessions"`, allowing the user to convert the 4-hour block into two 2-hour sessions with different categories.
- **User benefit:** Perfect recovery from forgotten stop taps without losing hours of productive work records.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/dialogs/smart_trim_sheet.dart:150`
- **Verification:** Open Smart Trim for 4-hour session; select 'Split into 2'; verify two distinct 2-hour sessions are created.

---

### IMP-188: Note Dialog Speech-to-Text Live Transcription Preview
- **Category:** Functional Intelligence / Accessibility
- **Current behaviour:** Taking a voice note saves audio, but requires manual playback to know what was said.
- **Proposed improvement:** Integrate offline on-device Android SpeechRecognizer (`RecognizerIntent.ACTION_RECOGNIZE_SPEECH`) to transcribe voice notes into the note body automatically.
- **User benefit:** Searchable text notes generated simultaneously with voice recordings without third-party cloud servers.
- **Implementation effort:** 3
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `android/app/src/main/kotlin/app/notekar/notekar/MainActivity.kt:340`
- **Verification:** Dictate voice note; verify spoken text transcribes cleanly into the text field below the recording bar.

---

### IMP-189: Timeline Media Attachment Aspect Ratio Preservation Grid
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/timeline_media_attachment_card.dart:60`, photo thumbnails are hardcoded to square 1:1 boxes, cropping tall documents or wide panoramic photos awkwardly.
- **Proposed improvement:** Support dynamic 4:3 and 16:9 aspect-ratio smart cropping with focal face/content detection.
- **User benefit:** Thumbnails show the important subject matter without cutting off document headings or faces.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_media_attachment_card.dart:75`
- **Verification:** Attach a vertical document photo; verify thumbnail crops intelligently to show the document header.

---

### IMP-190: Big Note Dialog Document Word Count Target Progress Bar
- **Category:** Functional Intelligence / Focus
- **Current behaviour:** `BigNoteDialog` shows current word count, but cannot track progress toward a specific writing target (e.g. 500-word daily journal).
- **Proposed improvement:** Allow setting a target word count (e.g. 500 words) with a subtle horizontal progress bar at the top of the canvas.
- **User benefit:** Motivates daily writing habits and keeps essay or journal drafts on target.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/dialogs/big_note_dialog.dart:165`
- **Verification:** Set 300-word goal; type 150 words; verify progress bar fills to 50% with encouragement badge.

---

### IMP-191: Swipeable Card Bed Haptic Detent on Reset to Zero
- **Category:** Tactile Feedback
- **Current behaviour:** When releasing a partially swiped card that snaps back to 0, it settles without haptic feedback.
- **Proposed improvement:** Fire a subtle `HapticFeedback.lightImpact()` as the card docks back home into its rest position.
- **User benefit:** Physical tactile confirmation that the card has securely returned to rest without performing an action.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/swipeable_card_bed.dart:160`
- **Verification:** Swipe card 20dp and let go; feel the soft home-docking click as the card springs back into alignment.

---

### IMP-192: Voice Memo Audio Waveform Active Scrub Handle Pip
- **Category:** Visual Polish
- **Current behaviour:** In `TimelineVoicePlayerPill`, the scrub position is represented by bar color only. There is no tangible scrubber thumb dot.
- **Proposed improvement:** Render a crisp 6dp circular accent bead on top of the active playback waveform bar during drag scrubbing.
- **User benefit:** Clear, pinpoint scrubber location affordance.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart:92`
- **Verification:** Drag across waveform; see illuminated accent bead tracking fingertip position precisely.

---

### IMP-193: Markdown Divider Thematic Break (`---`) Apple Hairline Styling
- **Category:** Visual Polish
- **Current behaviour:** In `lib/widgets/markdown_text.dart:130`, thematic horizontal rules (`---`) render as a standard 16dp tall Material Divider.
- **Proposed improvement:** Style horizontal dividers as a delicate 0.5dp hairline border (`p.border.withValues(alpha: 0.5)`) with 12dp vertical padding.
- **User benefit:** Clean, subtle thematic section divisions that maintain Apple HIG elegance.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/markdown_text.dart:132`
- **Verification:** Render note with `---`; observe subtle, refined separator line without heavy Material shadows.

---

### IMP-194: Note Preview Sheet Fullscreen Mode with Keyboard Navigation
- **Category:** Accessibility / Power Users
- **Current behaviour:** `NotePreviewSheet` is always a bottom sheet. On desktop or large Android foldables, it occupies only the bottom half of the display.
- **Proposed improvement:** Automatically expand to a centered, full-height dialog when screen width exceeds 600dp (tablets, foldables, Chromebooks).
- **User benefit:** Optimized reading layout taking full advantage of large foldable and tablet screens.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/note_preview_sheet.dart:105`
- **Verification:** Open note preview on a tablet or unfolded foldable; observe spacious, centered reading document modal.

---

### IMP-195: Timeline Single Tile Quick Tag Chip Direct Filter Tap
- **Category:** User Flows / Shortcuts
- **Current behaviour:** In `lib/widgets/timeline_single_tile.dart:170-195`, tapping a hashtag chip (e.g. `#gym`) inside a moment tile does nothing.
- **Proposed improvement:** Tapping any hashtag chip on a timeline card immediately applies that hashtag as the active timeline filter, showing all matching moments.
- **User benefit:** Instant contextual search: tap `#meeting` to immediately see all meeting notes from this month.
- **Implementation effort:** 2
- **User impact:** 5
- **Priority:** P1
- **Implementation location:** `lib/widgets/timeline_single_tile.dart:180`
- **Verification:** Tap `#focus` tag on any timeline card; verify timeline instantly filters to show all moments tagged `#focus`.

---

### IMP-196: Voice Memo Playback Audio Waveform Silence Compression
- **Category:** Audio / Polish
- **Current behaviour:** If a voice note contains 5 seconds of silence at the beginning, playback waits through the dead air.
- **Proposed improvement:** Add a "Skip Silence" toggle in the voice player that detects amplitudes below 0.05 RMS and accelerates playback through silent pauses at 3.0x speed.
- **User benefit:** Saves substantial listening time when reviewing long audio recordings and voice notes.
- **Implementation effort:** 3
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/services/audio_service.dart:190`
- **Verification:** Record voice note with long pause; enable Skip Silence; observe player zip through the silence instantly.

---

### IMP-197: Photo Lightbox File Information Metadata Sheet
- **Category:** Discoverability / Functional
- **Current behaviour:** `PhotoLightboxDialog` displays the image, but does not show file dimensions, storage size, or capture timestamp.
- **Proposed improvement:** Add an "Info" (ⓘ) button in the header that displays a compact modal with: Resolution (e.g. `1920x1080`), File Size (e.g. `480 KB`), and Format (`JPEG / WebP`).
- **User benefit:** Useful technical details for managing sovereign local storage and file backups.
- **Implementation effort:** 1
- **User impact:** 3
- **Priority:** P2
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart:210`
- **Verification:** Tap Info button in lightbox; view clean metadata summary sheet showing exact resolution and file weight.

---

### IMP-198: Timeline Session Card In-Progress Milestone Marker Flags
- **Category:** Delight / Visual Polish
- **Current behaviour:** Ongoing sessions display duration, but provide no visual indication when a personal milestone (e.g. 1 hour, 2 hours, 4 hours deep focus) is achieved during the session.
- **Proposed improvement:** Render a miniature glowing flag on the session card when a duration milestone is crossed during an ongoing session.
- **User benefit:** Encouraging real-time reinforcement during grueling work or study marathons.
- **Implementation effort:** 2
- **User impact:** 4
- **Priority:** P2
- **Implementation location:** `lib/widgets/timeline_session_card.dart:170`
- **Verification:** Let session pass 60 minutes; observe gentle golden milestone flag appear on the live card.

---

### IMP-199: Markdown Strikethrough Visual Opacity Dimming
- **Category:** Visual Polish / Typography
- **Current behaviour:** Text wrapped in `~~strikethrough~~` displays a line through the letters, but retains 100% full text contrast, competing visually with incomplete tasks.
- **Proposed improvement:** In addition to `TextDecoration.lineThrough`, apply `color: p.text3.withValues(alpha: 0.65)`.
- **User benefit:** Struck-through completed tasks visually recede, allowing remaining tasks to stand out clearly.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/widgets/markdown_text.dart:55`
- **Verification:** View completed checklist item in note; verify text dims to subtle tertiary grey with strike line.

---

### IMP-200: Merge Entries Unify Tags Deduplication
- **Category:** Data Integrity / Reliability
- **Current behaviour:** In `lib/dialogs/merge_entries_sheet.dart:140`, merging moments with duplicate tags (`#work`, `#work`) can concatenate them into duplicate tag arrays.
- **Proposed improvement:** Automatically pass merged tags through a case-insensitive `toSet().toList()` deduplication pipeline.
- **User benefit:** Clean tag databases without redundant duplicate tag pills.
- **Implementation effort:** 1
- **User impact:** 4
- **Priority:** P1
- **Implementation location:** `lib/dialogs/merge_entries_sheet.dart:145`
- **Verification:** Merge two moments both tagged `#focus`; verify resulting merged session contains exactly one `#focus` tag.
