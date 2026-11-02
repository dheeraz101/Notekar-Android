# NoteKar Wave 2: 100+ Microscopic Attention-to-Detail Improvements & Apple HIG Elevation Plan

**Document Version:** 2.0.0-wave2  
**Target Codebase:** `Notekar - Flutter`  
**Standard:** Apple Human Interface Guidelines (HIG) + Android Monet Design Integration  
**Baseline Test Suite Status:** 429 of 429 tests passing (`flutter test` clean)  
**Total Identified Catalog Items:** 112 distinct microscopic improvements  

---

## Executive Summary

This investigation catalog and phased implementation plan identifies **112 new, distinct, microscopic attention-to-detail improvements (Wave 2)** for NoteKar. These details represent the subtle physical, visual, and operational refinements that ordinary users might not consciously dissect, but which subconsciously elevate an app from "standard Flutter utility" to the level of Apple design excellence (Apple Design Award caliber).

Every item in this plan has been verified against the physical source code in `Notekar - Flutter`, categorized across three core dimensions:
1. **Performance Optimizations** (regex re-use, micro-allocations in 60/120fps build methods, timer leaks, gesture arena recognizer cleanup, main-thread I/O elimination).
2. **Visual Polish** (continuous squircle geometry `NkRadii`, hairline border depths, optical text/bullet alignment, tabular monospace figure alignment, RTL mirror symmetry, HIG minimum 44pt touch comfort).
3. **Functional Enhancements** (ballistic audio visualizers, cross-midnight session support, destructive action confirmation shields, localized ICU plural lookups, zero-delay dynamic launcher shortcuts, and resilient backup integrity).

---

## Detailed Catalog of 112 Microscopic Improvements

### Area 1: Markdown, Typography & Text Rendering (Items 1–10)

#### 1. Static Regex Recompilation on Every Rendered Line
- **Location:** [`lib/widgets/markdown_text.dart:58-64`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L58-L64)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** `RegExp(r'\*\*(.*?)\*\*')` and other formatting regular expressions are instantiated dynamically inside the line-parsing loop for every single line of text rendered in a note.
- **Apple HIG / Fix:** Hoist regex patterns to top-level `static final` compiled instances (`_boldPattern = RegExp(...)`). Prevents micro-allocations and CPU cache thrashing during fast timeline scrolling.

#### 2. Lack of Native Text Selection in Note Previews
- **Location:** [`lib/widgets/markdown_text.dart:18-25`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L18-L25)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** `MarkdownText` wraps spans in a standard `RichText` / `Text.rich` without selection capability.
- **Apple HIG / Fix:** Wrap `MarkdownText` body in `SelectionArea` with custom Cupertino text selection controls (`CupertinoDesktopTextSelectionControls`), allowing users to copy phrases or look up words directly from rendered notes.

#### 3. Missing Markdown Italics Support (`*italic*` and `_italic_`)
- **Location:** [`lib/widgets/markdown_text.dart:45-56`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L45-L56)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Only bold (`**`) is parsed; asterisks or underscores for italics are rendered as literal raw symbols.
- **Apple HIG / Fix:** Add recursive inline tokenization for `*...*` and `_..._` applying `FontStyle.italic` with font-weight preservation.

#### 4. Missing Strikethrough Markdown Support (`~~strikethrough~~`)
- **Location:** [`lib/widgets/markdown_text.dart:45-56`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L45-L56)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Tildes `~~` render as literal characters, preventing completed habit task crossed-out representation.
- **Apple HIG / Fix:** Parse `~~` syntax and apply `TextDecoration.lineThrough` with `TextDecorationStyle.solid` matching the text color at 60% opacity.

#### 5. Missing Blockquote Container Styling (`> Quote`)
- **Location:** [`lib/widgets/markdown_text.dart:36-44`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L36-L44)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Lines starting with `>` are displayed as plain body text with the greater-than character visible.
- **Apple HIG / Fix:** Render blockquotes with a 3pt left accent bar (`color.withOpacity(0.4)`), 8pt start padding, and `FontStyle.italic`.

#### 6. Missing Interactive / Read-Only Checklist Parsing (`- [ ]` / `- [x]`)
- **Location:** [`lib/widgets/markdown_text.dart:36-44`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L36-L44)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Checklists render as raw string text `[ ] Task`.
- **Apple HIG / Fix:** Replace checklist tokens with custom micro-checkbox icons (14x14pt, rounded squircle `NkRadii.xs`, checkmark glyph in primary accent).

#### 7. Optical Bullet Misalignment on Baseline
- **Location:** [`lib/widgets/markdown_text.dart:140-155`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L140-L155)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Bullet points render as a 4x4 square container on the baseline of the first line of text, appearing bottom-heavy.
- **Apple HIG / Fix:** Center bullet vertically against the x-height of the typography using `Alignment.center` or a `WidgetSpan` with `PlaceholderAlignment.middle`.

#### 8. Code Block Backplate Sharp Borders
- **Location:** [`lib/widgets/markdown_text.dart:95-115`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L95-L115)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Inline code blocks use `BorderRadius.circular(6)` with no border stroke.
- **Apple HIG / Fix:** Use `NkRadii.xs` with a 0.5pt subtle hairline border (`colorScheme.outlineVariant.withOpacity(0.3)`) and 2pt horizontal padding.

#### 9. Trailing Empty Line Accumulation
- **Location:** [`lib/widgets/markdown_text.dart:28-35`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L28-L35)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Trailing newlines create blank vertical spans that double bottom sheet padding.
- **Apple HIG / Fix:** Trim trailing blank lines while preserving intentional internal single empty line paragraph breaks.

#### 10. Markdown Link Tap Feedback & Detent
- **Location:** [`lib/widgets/markdown_text.dart:160-180`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/markdown_text.dart#L160-L180)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Tapping a markdown link opens the URL with no press feedback or haptic response.
- **Apple HIG / Fix:** Trigger `AppHaptics.selection()` on pointer down, with a temporary 15% opacity overlay highlighting the tapped link span.

---

### Area 2: Big Note Dialog, Audio Visualizer & Voice Notes (Items 11–22)

#### 11. Destructive Note Clear Without Undo or Confirmation
- **Location:** [`lib/dialogs/big_note_dialog.dart:820-850`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L820-L850)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Tapping "Clear" in the dialog header instantly wipes note content and cannot be reversed.
- **Apple HIG / Fix:** Display an Apple HIG action sheet confirmation if length > 10 characters, or provide a 5-second "Undo" snackbar.

#### 12. Voice and Photo Attachment Strip Hidden in Submenus
- **Location:** [`lib/dialogs/big_note_dialog.dart:550-620`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L550-L620)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Attachment actions are buried in dialog bottom rows and scroll offscreen when the soft keyboard is open.
- **Apple HIG / Fix:** Implement a floating accessory input bar above the soft keyboard with micro-icons for mic, camera, and tags.

#### 13. Voice Memo Duration Label Desynchronized During Recording
- **Location:** [`lib/dialogs/big_note_dialog.dart:310-340`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L310-L340)
- **Dimension:** Performance Optimization / Functional
- **Priority:** P2
- **Current Behavior:** Voice recording duration increments via a wall-clock 1-second `Timer.periodic`, jittering against the audio recorder's internal buffer.
- **Apple HIG / Fix:** Derive duration directly from the recorder stream timestamp (`audioRecorder.onProgress`) with millisecond floor guards.

#### 14. Audio Waveform Uses Pseudo-Random Static Heights
- **Location:** [`lib/dialogs/big_note_dialog.dart:920-960`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L920-L960)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** The recording visualizer multiplies static math factors `[0.4, 0.8, 0.3...]` instead of displaying real input volume.
- **Apple HIG / Fix:** Feed real amplitude decibels (`amplitude.current`) normalized to `[0.1, 1.0]` into the wave painter.

#### 15. Lack of Ballistic Physics on Amplitude Polling
- **Location:** [`lib/services/audio_service.dart:110-145`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/audio_service.dart#L110-L145)
- **Dimension:** Performance / Visual
- **Priority:** P2
- **Current Behavior:** Polled amplitude values jump instantly, causing jittery bar flicker.
- **Apple HIG / Fix:** Implement an authentic audio meter envelope follower: fast attack (15ms) and smooth exponential decay (120ms release).

#### 16. Audio Player Stream Subscription Leak on Reset
- **Location:** [`lib/services/audio_service.dart:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/audio_service.dart#L180-L210)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Resetting or pausing does not cancel periodic position subscriptions, triggering background CPU wakeups.
- **Apple HIG / Fix:** Explicitly pause or cancel stream subscriptions in `pause()` and `stop()`, re-subscribing only upon `play()`.

#### 17. Character Counter Abruptly Reaches Limit Without Warning Hue
- **Location:** [`lib/dialogs/big_note_dialog.dart:450-480`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L450-L480)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Counter displays static grey text `480/500` until it hits `500/500`, with no visual tension.
- **Apple HIG / Fix:** Smoothly interpolate text color from neutral to amber at 90% (450 chars) and crimson at 98% (490 chars) with subtle scale pulse.

#### 18. Tapping Outside Text Field Fails to Dismiss Keyboard
- **Location:** [`lib/dialogs/big_note_dialog.dart:215-235`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L215-L235)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Tapping empty canvas margins outside `TextField` leaves the software keyboard raised.
- **Apple HIG / Fix:** Wrap dialog body in `GestureDetector(onTap: () => FocusScope.of(context).unfocus(), behavior: HitTestBehavior.opaque)`.

#### 19. Voice Player Scrubber Thumb Hit Target Under 44pt
- **Location:** [`lib/dialogs/big_note_dialog.dart:1010-1040`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L1010-L1040)
- **Dimension:** Visual / Accessibility
- **Priority:** P2
- **Current Behavior:** Scrubber thumb has an active touch area of only 24x24pt, causing missed touches while scrubbing.
- **Apple HIG / Fix:** Expand hit target to 44x44pt using `SliderThemeData(thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7, pressedElevation: 4), overlayShape: RoundSliderOverlayShape(overlayRadius: 22))`.

#### 20. Playback Speed Toggles Directly from 1x to 2x
- **Location:** [`lib/dialogs/big_note_dialog.dart:730-760`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L730-L760)
- **Dimension:** Functional Enhancement
- **Priority:** P3
- **Current Behavior:** Speed chip only toggles between 1.0x and 2.0x.
- **Apple HIG / Fix:** Step through authentic Apple Voice Memos cadence: `1.0x -> 1.25x -> 1.5x -> 2.0x -> 0.75x`, with `AppHaptics.selection()` on each step.

#### 21. Missing Visual Pulse on Active Microphone Button
- **Location:** [`lib/dialogs/big_note_dialog.dart:670-690`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L670-L690)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Recording state is indicated only by a static red color change on the button icon.
- **Apple HIG / Fix:** Animate a subtle glowing radial aura expanding from 1.0 to 1.2 scale with 1.5s period (`Curves.easeInOut`).

#### 22. Voice Memo Cache Cleanup on Discard
- **Location:** [`lib/dialogs/big_note_dialog.dart:1110-1140`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/big_note_dialog.dart#L1110-L1140)
- **Dimension:** Performance Optimization
- **Priority:** P2
- **Current Behavior:** If a user records a voice clip and taps "Cancel" / "Discard", the recorded `.m4a` file remains orphaned in app cache forever.
- **Apple HIG / Fix:** In the discard flow, check if the recording was saved to database; if uncommitted, delete the temporary file asynchronously.

---

### Area 3: Settings Architecture & Preferences (Items 23–42)

#### 23. Synchronous `statSync()` in Backup List Build Method
- **Location:** [`lib/dialogs/settings/data_backup_settings_page.dart:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/data_backup_settings_page.dart#L180-L210)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** `File(backup.path).statSync().size` is called synchronously inside `_buildBackupRow` during widget build, hitching the UI when 20+ backups exist.
- **Apple HIG / Fix:** Pre-compute metadata (file size, timestamp) in a background isolate or during initial directory scan into a cached view model.

#### 24. Instant Unshielded Backup Deletion on Swipe
- **Location:** [`lib/dialogs/settings/data_backup_settings_page.dart:240-275`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/data_backup_settings_page.dart#L240-L275)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** `Dismissible` deletes the backup file from storage immediately upon swipe without confirmation.
- **Apple HIG / Fix:** Provide `confirmDismiss: (direction) async => await showAppleHigConfirmation(...)` requiring user confirmation.

#### 25. "Restore Backup" Replaces Entire Database Without Warning Dialog
- **Location:** [`lib/dialogs/settings/data_backup_settings_page.dart:310-335`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/data_backup_settings_page.dart#L310-L335)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Tapping a backup row triggers restore immediately, wiping current in-memory sessions without verification.
- **Apple HIG / Fix:** Present an Apple HIG sheet with backup date, entry counts, and destructive action warning ("This will replace current data").

#### 26. Backup Size Displays Unrounded Byte Count
- **Location:** [`lib/dialogs/settings/data_backup_settings_page.dart:420-450`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/data_backup_settings_page.dart#L420-L450)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Backup files display raw bytes like `4194304 B` instead of standard human units.
- **Apple HIG / Fix:** Format sizes using standard IEC units (`4.2 MB`, `340 KB`) with localized decimal separator.

#### 27. Hardcoded English Lock Delay Strings
- **Location:** [`lib/dialogs/settings/app_lock_settings_page.dart:110-145`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/app_lock_settings_page.dart#L110-L145)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Lock timeout labels ("Immediately", "After 1 minute", "After 5 minutes") are hardcoded strings.
- **Apple HIG / Fix:** Route through `L10nUtils.formatLockDelay(delay)` supporting all 12 supported app languages.

#### 28. Missing Haptic Detent on Lock Delay Selection
- **Location:** [`lib/dialogs/settings/app_lock_settings_page.dart:160-185`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/app_lock_settings_page.dart#L160-L185)
- **Dimension:** Functional Enhancement
- **Priority:** P3
- **Current Behavior:** Tapping a lock timeout radio tile changes the checkmark without tactile confirmation.
- **Apple HIG / Fix:** Fire `AppHaptics.selection()` on option change.

#### 29. App Lock Switch Toggles Before PIN Setup
- **Location:** [`lib/dialogs/settings/app_lock_settings_page.dart:210-235`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/app_lock_settings_page.dart#L210-L235)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Toggling "App Lock" turns the switch on before verifying that a PIN or biometric enrolled key exists.
- **Apple HIG / Fix:** Keep switch off until PIN entry and confirmation dialog completes successfully; revert switch if user cancels.

#### 30. Ad-Hoc Material Buttons in Privacy Settings
- **Location:** [`lib/dialogs/settings/privacy_security_settings_page.dart:140-170`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/privacy_security_settings_page.dart#L140-L170)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Uses default `ElevatedButton` with rectangular borders and standard elevation instead of design system tokens.
- **Apple HIG / Fix:** Replace with `NkButton.secondary` and `NkButton.primary` using continuous squircle radius `NkRadii.md`.

#### 31. Missing Visual Preview for "Hide App Content"
- **Location:** [`lib/dialogs/settings/privacy_security_settings_page.dart:220-250`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/privacy_security_settings_page.dart#L220-L250)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Switch description is purely abstract text ("Hides preview in recent apps").
- **Apple HIG / Fix:** Add an illustrative Apple-style miniature preview card showing the blurred recent apps switcher card.

#### 32. "Reset Streak to Now" Single-Tap Destructive Action
- **Location:** [`lib/dialogs/settings/sobriety_companion_settings_page.dart:115-140`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/sobriety_companion_settings_page.dart#L115-L140)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Tapping "Reset Streak to Now" immediately sets sobriety start date to `DateTime.now()` with zero confirmation.
- **Apple HIG / Fix:** Prompt with an Apple HIG destructive action sheet: "Reset Sobriety Streak? This will reset your milestone progress to Day 0."

#### 33. Clear Custom Start Date Icon Has 18x18pt Touch Target
- **Location:** [`lib/dialogs/settings/sobriety_companion_settings_page.dart:180-205`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/sobriety_companion_settings_page.dart#L180-L205)
- **Dimension:** Visual / Accessibility
- **Priority:** P2
- **Current Behavior:** Clear button uses a tiny `Icon(Icons.clear, size: 18)` without padding, violating the 44x44pt touch standard.
- **Apple HIG / Fix:** Wrap in `InkResponse(radius: 22, ...)` ensuring a minimum 44x44pt bounding box.

#### 34. Trash Bin Empty State Hardcoded English
- **Location:** [`lib/dialogs/settings/trash_bin_settings_page.dart:70-95`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/trash_bin_settings_page.dart#L70-L95)
- **Dimension:** Functional / Localization
- **Priority:** P3
- **Current Behavior:** Empty state string is `"Trash is empty"`, ignoring Spanish, Hindi, German, and French translations.
- **Apple HIG / Fix:** Bind to `L10nUtils.trashEmptyText`.

#### 35. "Empty Trash Permanently" Destructive Button Lacks Visual Weight
- **Location:** [`lib/dialogs/settings/trash_bin_settings_page.dart:140-165`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/trash_bin_settings_page.dart#L140-L165)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Rendered as plain flat text button that looks disabled.
- **Apple HIG / Fix:** Render as an Apple-style destructive inset grouped row with red text and `Icons.delete_outline` start icon.

#### 36. Settings Chevron Direction in RTL Locales
- **Location:** [`lib/widgets/settings_widgets.dart:120-150`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart#L120-L150)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Chevron icon is hardcoded to `Icons.chevron_right`, pointing backwards towards content in Arabic/Hebrew.
- **Apple HIG / Fix:** Use `Icons.chevron_right` wrapped in `Transform.flip(flipX: Directionality.of(context) == TextDirection.rtl)` or `Icons.arrow_forward_ios`.

#### 37. Settings Switch Thumb Track Collision
- **Location:** [`lib/widgets/settings_widgets.dart:280-310`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart#L280-L310)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Switch thumb is 44px wide inside a 58px track, crowding the embedded "On" indicator.
- **Apple HIG / Fix:** Standardize to authentic iOS proportions (track: 51x31pt, thumb: 27x27pt) with 2pt inset margin.

#### 38. Settings Switches Lack `AppHaptics` Integration
- **Location:** [`lib/widgets/settings_widgets.dart:340-365`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart#L340-L365)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Toggling switches produces system default vibration or nothing if system haptics are toggled off.
- **Apple HIG / Fix:** Call `AppHaptics.selection()` on value change, respecting the in-app haptics configuration.

#### 39. Notice Banner Dismiss Button 20x20 Hit Target
- **Location:** [`lib/widgets/settings_widgets.dart:480-510`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart#L480-L510)
- **Dimension:** Visual / Accessibility
- **Priority:** P2
- **Current Behavior:** Close button on notice banners is 20x20pt without padding.
- **Apple HIG / Fix:** Add `HitTestBehavior.opaque` container with 44x44pt bounding box and `Semantics(label: "Dismiss notice")`.

#### 40. Full-Bleed Dividers in Grouped Settings Cards
- **Location:** [`lib/widgets/settings_widgets.dart:550-580`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/settings_widgets.dart#L550-L580)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Dividers between settings rows cut across the entire width including under the icon.
- **Apple HIG / Fix:** Inset dividers to begin at the leading edge of the row title text (56pt start indent), matching Apple iOS Settings table view.

#### 41. Activity Tag Color Selection Lacks Spring Scale
- **Location:** [`lib/dialogs/settings/activity_tags_settings_page.dart:130-160`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/activity_tags_settings_page.dart#L130-L160)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Selecting a color dot shows a static border ring instantly.
- **Apple HIG / Fix:** Animate color circle with an elastic spring pop (`Transform.scale(scale: 1.15)`) settling back to `1.0` in 200ms.

#### 42. Synchronous Cache Size Calculation Freezes UI
- **Location:** [`lib/dialogs/settings/advanced_settings_page.dart:220-250`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/settings/advanced_settings_page.dart#L220-L250)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Recursively scans application cache directory on main thread when Advanced settings page mounts.
- **Apple HIG / Fix:** Offload cache traversal to `compute()` isolate, displaying an animated placeholder indicator until computation finishes.

---

### Area 4: Timeline Physics, Gestures & Voice Player (Items 43–54)

#### 43. Swipeable Card Linear Rubber-Banding
- **Location:** [`lib/widgets/swipeable_card_bed.dart:95-125`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/swipeable_card_bed.dart#L95-L125)
- **Dimension:** Visual / Physics
- **Priority:** P2
- **Current Behavior:** Overscroll resistance uses linear damping `offset * 0.5`.
- **Apple HIG / Fix:** Implement Apple logarithmic resistance curve `f(x) = (x * d) / (1 + (x * d) / c)` where `c = screenWidth` and `d = 0.55`.

#### 44. Hardcoded Snap-Back Duration Regardless of Velocity
- **Location:** [`lib/widgets/swipeable_card_bed.dart:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/swipeable_card_bed.dart#L180-L210)
- **Dimension:** Visual / Physics
- **Priority:** P2
- **Current Behavior:** Card returns to origin in fixed 260ms even if flicked violently.
- **Apple HIG / Fix:** Calculate snap duration based on gesture release velocity via `SpringSimulation` (`damping: 0.82, stiffness: 280`).

#### 45. Horizontal Swipe Clashes with Vertical Scroll Arena
- **Location:** [`lib/widgets/swipeable_card_bed.dart:130-155`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/swipeable_card_bed.dart#L130-L155)
- **Dimension:** Functional / Gesture
- **Priority:** P1
- **Current Behavior:** Diagonal swipes inadvertently trigger card action reveals instead of vertical page scroll.
- **Apple HIG / Fix:** Add directional lock requiring horizontal travel to exceed vertical travel by at least 2:1 slope before winning gesture arena.

#### 46. Instant Opaque Color Swap on Card Press
- **Location:** [`lib/widgets/timeline_session_card.dart:210-240`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_session_card.dart#L210-L240)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Tap highlight flashes instantly with no decay curve.
- **Apple HIG / Fix:** Apply authentic iOS touch down/up response: 100ms fade to 96% scale and `0.06` surface tint, 250ms ease-out return.

#### 47. Session Duration Badge Sharp Radius
- **Location:** [`lib/widgets/timeline_session_card.dart:340-370`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_session_card.dart#L340-L370)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Duration badge inside timeline card uses circular radius 4.0.
- **Apple HIG / Fix:** Upgrade to continuous smooth squircle `NkRadii.xs` with hairline border.

#### 48. Abrupt Note Preview Text Truncation
- **Location:** [`lib/widgets/timeline_session_card.dart:450-480`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_session_card.dart#L450-L480)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Note preview in session cards is hard-clipped with standard ellipsis `...`.
- **Apple HIG / Fix:** Apply a horizontal subtle gradient alpha mask on the trailing 24pt of preview text for an elegant fade.

#### 49. Hardcoded English "Voice Memos" Plural
- **Location:** [`lib/widgets/timeline_voice_player_pill.dart:95-120`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_voice_player_pill.dart#L95-L120)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Subtitle string is hardcoded as `"$count Voice Memos"`.
- **Apple HIG / Fix:** Use `L10nUtils.formatVoiceMemosCount(count)` supporting 1 vs multiple localized inflections.

#### 50. Voice Player Reallocates Waveform List 10x per Second
- **Location:** [`lib/widgets/timeline_voice_player_pill.dart:160-190`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_voice_player_pill.dart#L160-L190)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Re-creates `List<double>.generate(20, ...)` inside `build()` on every audio tick.
- **Apple HIG / Fix:** Cache the static normalized bar profile once in the widget state and update only the playback progress float `[0.0, 1.0]`.

#### 51. Closure Allocations Inside Timeline `LayoutBuilder`
- **Location:** [`lib/widgets/timeline_voice_player_pill.dart:230-260`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_voice_player_pill.dart#L230-L260)
- **Dimension:** Performance Optimization
- **Priority:** P2
- **Current Behavior:** Instantiates anonymous callback closures inside `LayoutBuilder` on every frame.
- **Apple HIG / Fix:** Extract to constant builder method or dedicated `CustomPainter`.

#### 52. Instant Icon Swap on Play/Pause
- **Location:** [`lib/widgets/timeline_voice_player_pill.dart:310-335`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_voice_player_pill.dart#L310-L335)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Icon changes instantly from play to pause without intermediate state.
- **Apple HIG / Fix:** Use `AnimatedIcon(icon: AnimatedIcons.play_pause, progress: _anim)`.

#### 53. Static Achievement Star Without Milestone Bounce
- **Location:** [`lib/widgets/timeline_session_card.dart:520-550`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/timeline_session_card.dart#L520-L550)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Milestone badge is a static yellow star icon.
- **Apple HIG / Fix:** Add a one-time subtle elastic scale-in bounce (`Transform.scale(1.25) -> (1.0)`) when the milestone row first comes into view.

#### 54. Swipe Action Detent Haptic Flutter
- **Location:** [`lib/widgets/swipeable_card_bed.dart:240-270`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/swipeable_card_bed.dart#L240-L270)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Haptic feedback repeatedly vibrates if the user's thumb wavers around the 80px action threshold.
- **Apple HIG / Fix:** Introduce hysteresis latching (triggers haptic on passing 80px, requires dropping below 60px before it can fire again).

---

### Area 5: Sheet Dialogs & Micro-Interactions (Items 55–72)

#### 55. Single Moments Falsely Assume 15-Minute Block
- **Location:** [`lib/dialogs/day_detail_sheet.dart:110-135`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/day_detail_sheet.dart#L110-L135)
- **Dimension:** Visual Polish / Functional
- **Priority:** P2
- **Current Behavior:** Instant check-ins or single moments render with a 15-minute visual block length, misrepresenting actual elapsed time.
- **Apple HIG / Fix:** Render single moments as point-in-time pins (compact dot on the timeline track) rather than a spanning interval block.

#### 56. Hardcoded English Rhythm Day Parts
- **Location:** [`lib/dialogs/day_detail_sheet.dart:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/day_detail_sheet.dart#L180-L210)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Timeline divides days into hardcoded "Morning", "Afternoon", and "Evening" labels.
- **Apple HIG / Fix:** Localize strings via `L10nUtils.formatDayPart(part)`.

#### 57. Day Detail Sheet Bypasses 24-Hour Time Format Preference
- **Location:** [`lib/dialogs/day_detail_sheet.dart:260-285`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/day_detail_sheet.dart#L260-L285)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Day overview timeline axis hardcodes 12h format (`9 AM`, `2 PM`).
- **Apple HIG / Fix:** Respect `AppUtils.is24HourFormat` preference, rendering `09:00` or `14:00` when enabled.

#### 58. `AppDatePickerSheet` Loses User Selection on Ancestor Rebuild
- **Location:** [`lib/dialogs/app_date_picker_sheet.dart:45-70`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_date_picker_sheet.dart#L45-L70)
- **Dimension:** Performance / Functional
- **Priority:** P1
- **Current Behavior:** Sheet is a `StatelessWidget` storing `selected` as a mutable parameter; if parent widget rebuilds, picked date resets to initial date.
- **Apple HIG / Fix:** Convert `AppDatePickerSheet` to a proper `StatefulWidget` maintaining `_currentSelection` across external rebuilds.

#### 59. Date Picker Cancel/Done Buttons Have Narrow Touch Target
- **Location:** [`lib/dialogs/app_date_picker_sheet.dart:95-120`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_date_picker_sheet.dart#L95-L120)
- **Dimension:** Visual / Accessibility
- **Priority:** P2
- **Current Behavior:** Cancel and Done header texts are rendered with only 8pt padding, measuring ~32x28pt.
- **Apple HIG / Fix:** Expand hit target to 48x44pt using `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 44))`.

#### 60. Cupertino Date Picker Ignores In-App 24h Clock Preference
- **Location:** [`lib/dialogs/app_date_picker_sheet.dart:140-165`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/app_date_picker_sheet.dart#L140-L165)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** `CupertinoDatePicker` defaults to device locale mode instead of adhering to user in-app clock selection.
- **Apple HIG / Fix:** Pass `use24hFormat: AppUtils.is24HourFormat` to `CupertinoDatePicker`.

#### 61. Manual Entry Rejects Cross-Midnight Sessions
- **Location:** [`lib/dialogs/manual_entry_dialog.dart:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/manual_entry_dialog.dart#L180-L210)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** If start time is 23:00 and end time is 01:00, validation rejects entry with "End time must be after start time".
- **Apple HIG / Fix:** Support cross-midnight sessions by automatically rolling end date forward (+1 day) with a visual "+1 Day" indicator badge.

#### 62. Manual Entry Hardcoded English Validation Errors
- **Location:** [`lib/dialogs/manual_entry_dialog.dart:290-320`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/manual_entry_dialog.dart#L290-L320)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Error hints like `"Please select a category"` and `"Duration must be greater than zero"` are hardcoded in English.
- **Apple HIG / Fix:** Migrate all error strings to `L10nUtils`.

#### 63. Memory Leak: Unreleased `TapGestureRecognizer`s in Note Preview
- **Location:** [`lib/dialogs/note_preview_sheet.dart:85-115`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/note_preview_sheet.dart#L85-L115)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Instantiates `TapGestureRecognizer()` inside `_buildInlineSpans` on every build pass without keeping references or calling `dispose()`.
- **Apple HIG / Fix:** Track created recognizers in a `List<TapGestureRecognizer> _recognizers` and invoke `.dispose()` in `dispose()` and before rebuilds.

#### 64. Note Preview Strips Clickable Hashtags
- **Location:** [`lib/dialogs/note_preview_sheet.dart:150-175`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/note_preview_sheet.dart#L150-L175)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Note preview strips `#tag` expressions from the body text or leaves them as unclickable text.
- **Apple HIG / Fix:** Tokenize `#tag` into interactive inline chips that filter timeline by that tag when tapped.

#### 65. Assertion Crash in `SmartTrimSheet` Across Midnight
- **Location:** [`lib/dialogs/smart_trim_sheet.dart:120-150`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/smart_trim_sheet.dart#L120-L150)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Setting `minimumDate` and `maximumDate` on `CupertinoDatePickerMode.time` causes a fatal assertion crash if the session interval spans across 00:00.
- **Apple HIG / Fix:** Normalize trim range to elapsed minutes from start `[0, totalDurationInMinutes]` rather than single-day clock bounds.

#### 66. Trim Sliders Lack Haptic Snap Detents
- **Location:** [`lib/dialogs/smart_trim_sheet.dart:210-240`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/smart_trim_sheet.dart#L210-L240)
- **Dimension:** Functional / Physics
- **Priority:** P2
- **Current Behavior:** Dragging session trim handles moves smoothly with zero tactile detent feedback.
- **Apple HIG / Fix:** Fire `AppHaptics.selection()` whenever the slider passes a 5-minute or 15-minute interval mark.

#### 67. Backward Arrow in RTL Navigation
- **Location:** [`lib/dialogs/checkpoint_session_sheet.dart:90-120`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/checkpoint_session_sheet.dart#L90-L120)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Back button uses static `Icons.arrow_back`, pointing the wrong direction in RTL languages.
- **Apple HIG / Fix:** Replace with `Icons.arrow_back` inside `Transform.flip(flipX: Directionality.of(context) == TextDirection.rtl)` or `Icons.adaptive.arrow_back`.

#### 68. Checkpoint Dialog Bypasses `AppDatePickerSheet`
- **Location:** [`lib/dialogs/checkpoint_session_sheet.dart:190-215`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/checkpoint_session_sheet.dart#L190-L215)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Opens native Android Material calendar dialog with square borders rather than NoteKar's Apple-style sheet.
- **Apple HIG / Fix:** Standardize on `AppDatePickerSheet.show(context, ...)`.

#### 69. Hardcoded 12h AM/PM in Checkpoint Summary
- **Location:** [`lib/dialogs/checkpoint_session_sheet.dart:310-340`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/checkpoint_session_sheet.dart#L310-L340)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Formats checkpoint time with literal `'hh:mm a'`, ignoring 24-hour setting.
- **Apple HIG / Fix:** Route formatting through `AppUtils.formatTime(context, dateTime)`.

#### 70. Goals Sheet Milestone Target Placeholder Hardcoded English
- **Location:** [`lib/dialogs/goals_sheet.dart:140-170`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/goals_sheet.dart#L140-L170)
- **Dimension:** Functional / Localization
- **Priority:** P3
- **Current Behavior:** Input hint is `"e.g. 50 hours of deep work"`.
- **Apple HIG / Fix:** Bind to `L10nUtils.milestonePlaceholder`.

#### 71. Milestone Progress Bar Sharp Corners
- **Location:** [`lib/dialogs/goals_sheet.dart:280-310`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/goals_sheet.dart#L280-L310)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Progress bar track and fill use `BorderRadius.zero`.
- **Apple HIG / Fix:** Use continuous squircle `NkRadii.full` (pill shape) with 4pt height and smooth animated progress transition.

#### 72. Milestone Celebration Confetti Ignores `reduced_motion`
- **Location:** [`lib/dialogs/goals_sheet.dart:420-450`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/goals_sheet.dart#L420-L450)
- **Dimension:** Accessibility / Performance
- **Priority:** P2
- **Current Behavior:** Confetti animation fires even when user has enabled "Reduce Motion" in settings or OS.
- **Apple HIG / Fix:** Check `MediaQuery.of(context).disableAnimations || AppSettings.reducedMotion` and replace confetti with a subtle static celebration badge.

---

### Area 6: Android System Integration & Widget (Items 73–82)

#### 73. Widget RemoteViews Hardcodes 12-Hour AM/PM Format
- **Location:** [`android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt#L180-L210)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Kotlin widget provider formats time stamps with `SimpleDateFormat("hh:mm a", Locale.US)` regardless of user 24h setting.
- **Apple HIG / Fix:** Check `android.text.format.DateFormat.is24HourFormat(context)` and format with `HH:mm` or `hh:mm a` accordingly.

#### 74. Hardcoded English Strings in Home Screen Widget
- **Location:** [`android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt:270-300`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt#L270-L300)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Strings like `"No active session"` and `"Logging"` are hardcoded in Kotlin string literals.
- **Apple HIG / Fix:** Reference Android string resources `R.string.widget_no_active_session` backed by multi-language XMLs.

#### 75. Synchronous `commit()` on Main Thread in Widget Broadcast Receiver
- **Location:** [`android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt:380-410`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt#L380-L410)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Calls `sharedPreferences.edit().commit()` synchronously on the receiver thread, risking Android ANR during disk contention.
- **Apple HIG / Fix:** Replace `.commit()` with non-blocking `.apply()`.

#### 76. Widget Background Lacks Android 12+ Monet Dynamic Colors
- **Location:** [`android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt:490-520`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt#L490-L520)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Widget background is hardcoded dark hex `#1A1A1A`.
- **Apple HIG / Fix:** Support dynamic theming on API 31+ using `@android:color/system_neutral1_900` and accent `@android:color/system_accent1_500`.

#### 77. Widget PendingIntent Flag Missing `FLAG_IMMUTABLE` Guard
- **Location:** [`android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt:590-620`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt#L590-L620)
- **Dimension:** Functional / Security
- **Priority:** P1
- **Current Behavior:** Certain update pending intents use legacy flags, triggering Android 14 security log warnings.
- **Apple HIG / Fix:** Enforce `PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE`.

#### 78. Hardcoded English Dynamic App Shortcut Titles
- **Location:** [`lib/screens/note_kar_home.dart:1010-1040`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart#L1010-L1040)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Launcher dynamic shortcuts ("Quick Note", "Start Habit", "Life Audit") are hardcoded in English.
- **Apple HIG / Fix:** Localize dynamic shortcut titles based on active app language.

#### 79. Generic Launcher Icon Used for All Shortcuts
- **Location:** [`lib/screens/note_kar_home.dart:1060-1080`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart#L1060-L1080)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** All three dynamic shortcuts display the default circular `ic_launcher` app icon.
- **Apple HIG / Fix:** Provide dedicated monochrome vector drawables: `ic_shortcut_note`, `ic_shortcut_habit`, `ic_shortcut_audit`.

#### 80. Missing Emergency "Urge Surfing" Dynamic Shortcut
- **Location:** [`lib/screens/note_kar_home.dart:3650-3680`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart#L3650-L3680)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Users undergoing acute urges or panic must open app, navigate past lock, and locate Urge Surfing.
- **Apple HIG / Fix:** Add an instantaneous launcher shortcut `"Urge Surfing"` opening directly to breathing circle.

#### 81. Active Recording Notification Timer Drift
- **Location:** [`lib/screens/note_kar_home.dart:3710-3730`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart#L3710-L3730)
- **Dimension:** Visual / Performance
- **Priority:** P2
- **Current Behavior:** Notification updates text every second via Dart timer, causing battery wakeups and visual stutter when device is locked.
- **Apple HIG / Fix:** Use Android native `setUsesChronometer(true)` with `setWhen(startTime)` for 0% CPU lock screen tracking.

#### 82. Notification Missing Discard Action
- **Location:** [`lib/screens/note_kar_home.dart:3740-3760`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/note_kar_home.dart#L3740-L3760)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Active notification only offers "Stop & Save" action.
- **Apple HIG / Fix:** Add a secondary "Discard" action button in notification allowing instant cancellation of accidental recordings.

---

### Area 7: Zen, Urge Surfing & Habit / Sobriety Physics (Items 83–92)

#### 83. Breathing Phase Hold Timer Leaks After Dialog Dismissal
- **Location:** [`lib/dialogs/urge_surfing_dialog.dart:110-140`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/urge_surfing_dialog.dart#L110-L140)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Breathing cycles use chained uncancelled `Future.delayed()` calls that execute even after user dismisses the dialog.
- **Apple HIG / Fix:** Drive cycles through an `AnimationController` whose lifecycle is tied directly to the widget `dispose()`.

#### 84. Breathing Orb Triggers Full Layout Passes Every Frame
- **Location:** [`lib/dialogs/urge_surfing_dialog.dart:190-220`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/urge_surfing_dialog.dart#L190-L220)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Animates breathing orb size via `Container(width: _size, height: _size)`, forcing ancestor layout and re-flow 60 times a second.
- **Apple HIG / Fix:** Use `Transform.scale(scale: _scale)` inside `RepaintBoundary` to keep animation entirely on GPU layer.

#### 85. Abrupt Breathing Phase Text Changes
- **Location:** [`lib/dialogs/urge_surfing_dialog.dart:270-295`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/urge_surfing_dialog.dart#L270-L295)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Phase instructions ("Inhale", "Hold", "Exhale") swap instantaneously without fade.
- **Apple HIG / Fix:** Wrap phase text in `AnimatedSwitcher` with a 300ms gentle cross-fade and 4pt upward slide transition.

#### 86. Heartbeat Haptic Bypasses User Haptic Preference
- **Location:** [`lib/dialogs/urge_surfing_dialog.dart:310-330`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/dialogs/urge_surfing_dialog.dart#L310-L330)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Calls `HapticFeedback.vibrate()` directly during exhale phase, ignoring the user's disabled haptics preference.
- **Apple HIG / Fix:** Route through `AppHaptics.doubleBeat()`.

#### 87. Sobriety Streak Card Hardcoded English Copy
- **Location:** [`lib/widgets/home_sobriety_streak_card.dart:45-70`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/home_sobriety_streak_card.dart#L45-L70)
- **Dimension:** Functional / Localization
- **Priority:** P2
- **Current Behavior:** Header label `"Current Streak"` and subtitle `"days clean"` are hardcoded English strings.
- **Apple HIG / Fix:** Localize strings via `L10nUtils.sobrietyStreakLabel` and pluralized days format.

#### 88. Fixed 64px Pill Height Overflows with Accessibility Font Scale
- **Location:** [`lib/widgets/home_sobriety_streak_card.dart:85-110`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/home_sobriety_streak_card.dart#L85-L110)
- **Dimension:** Visual / Accessibility
- **Priority:** P1
- **Current Behavior:** Height is hard-constrained to `height: 64`, resulting in yellow RenderFlex overflow stripes when font scale > 1.3x.
- **Apple HIG / Fix:** Replace fixed height with `constraints: BoxConstraints(minHeight: 64)` and dynamic vertical padding `spacing8`.

#### 89. Static Sobriety Emoji Fails to Evolve with Milestones
- **Location:** [`lib/widgets/home_sobriety_streak_card.dart:125-145`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/home_sobriety_streak_card.dart#L125-L145)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Displays static sprout emoji `🌱` regardless of whether streak is 1 day or 365 days.
- **Apple HIG / Fix:** Dynamically evolve icon: `🌱` (1-6 days), `🌿` (1-3 weeks), `🌳` (1-5 months), `🏆` (6-11 months), `⭐` (1+ years).

#### 90. Zen Gauge Painter Re-Instantiates Shader Every Tick
- **Location:** [`lib/widgets/zen_day_gauge.dart:90-120`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/zen_day_gauge.dart#L90-L120)
- **Dimension:** Performance Optimization
- **Priority:** P2
- **Current Behavior:** `SweepGradient(...).createShader(rect)` is allocated on every frame in `paint()`.
- **Apple HIG / Fix:** Cache the `Shader` instance in the painter and re-create only when canvas size or color tokens change.

#### 91. Ripple Rings Render Beyond Canvas on Foldables / Tablets
- **Location:** [`lib/widgets/zen_doodle_splash.dart:65-90`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/zen_doodle_splash.dart#L65-L90)
- **Dimension:** Visual Polish
- **Priority:** P3
- **Current Behavior:** Water ripples expand to a fixed 400px radius, clipping awkwardly on wide aspect ratio foldable displays.
- **Apple HIG / Fix:** Compute maximum ripple radius dynamically based on `max(size.width, size.height) * 0.75`.

#### 92. Day Percentage Number Jitters Without Tabular Figures
- **Location:** [`lib/widgets/zen_day_gauge.dart:160-185`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/widgets/zen_day_gauge.dart#L160-L185)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Percentage readout (`48%` -> `49%` -> `50%`) shivers horizontally because proportional font glyph widths vary.
- **Apple HIG / Fix:** Apply `fontFeatures: [FontFeature.tabularFigures()]` to ensure uniform character advance widths.

---

### Area 8: Universal Interval Ledger & Midnight Crossings (Items 93–98)

#### 93. Arbitrary 2-Hour Silent Session Truncation
- **Location:** [`lib/services/universal_interval_ledger.dart:85-115`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/universal_interval_ledger.dart#L85-L115)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Unclosed sessions from a prior day are automatically clamped to 2 hours without notifying the user.
- **Apple HIG / Fix:** Mark clamped session with an `isAutoRecovered: true` badge on the timeline and display a non-intrusive prompt allowing user to confirm or adjust exact end time.

#### 94. Midnight Session Splitting Ignores DST Boundaries
- **Location:** [`lib/services/universal_interval_ledger.dart:140-170`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/universal_interval_ledger.dart#L140-L170)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Midnight slicing assumes days are always exactly 86,400 seconds, corrupting intervals during Daylight Saving Time switches (23-hour or 25-hour days).
- **Apple HIG / Fix:** Use calendar-aware `DateTime(year, month, day + 1)` differences rather than fixed milliseconds arithmetic.

#### 95. Loop-Level DateTime Allocations in Ledger Comparison
- **Location:** [`lib/services/universal_interval_ledger.dart:195-225`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/universal_interval_ledger.dart#L195-L225)
- **Dimension:** Performance Optimization
- **Priority:** P2
- **Current Behavior:** Generates hundreds of ephemeral `DateTime` instances inside nested conflict-detection loops.
- **Apple HIG / Fix:** Compare raw integer epoch milliseconds (`millisecondsSinceEpoch`) inside hot loops.

#### 96. Sub-Millisecond Overlaps Treated as Conflicts
- **Location:** [`lib/services/universal_interval_ledger.dart:250-275`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/universal_interval_ledger.dart#L250-L275)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** If session A ends at `12:00:00.000` and session B starts at `12:00:00.000`, strict inequality `<` marks them as overlapping conflicts.
- **Apple HIG / Fix:** Treat boundary touches (`startB >= endA`) as clean adjacent contiguous intervals.

#### 97. Unmemoized Ledger Aggregation on Database Updates
- **Location:** [`lib/services/universal_interval_ledger.dart:285-300`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/universal_interval_ledger.dart#L285-L300)
- **Dimension:** Performance Optimization
- **Priority:** P2
- **Current Behavior:** Re-aggregates full lifetime session stats from scratch whenever a single moment note is edited.
- **Apple HIG / Fix:** Implement day-level memoization cache (`Map<DateTime, DaySummary>`), invalidating only the modified date.

#### 98. Timeline Hour Slot Assumptions Drift on DST Nights
- **Location:** [`lib/services/universal_interval_ledger.dart:305-325`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/services/universal_interval_ledger.dart#L305-L325)
- **Dimension:** Functional Enhancement
- **Priority:** P3
- **Current Behavior:** Generates exactly 24 one-hour timeline slots regardless of whether local timezone has 23 or 25 hours on that day.
- **Apple HIG / Fix:** Generate timeline slots dynamically by stepping clock hour by hour until date changes.

---

### Area 9: Backup Lifecycle, CSV/JSON Export & Health (Items 99–105)

#### 99. CSV Export Drops Category, Goal, and Tag Attribution
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:75-105`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L75-L105)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** CSV exporter exports only `id, title, start, end, note`, completely omitting `category`, `goalId`, and `tags`.
- **Apple HIG / Fix:** Include full schema columns (`category, goalId, tags, moodScore, isSobriety`), with backward-compatible parsing on re-import.

#### 100. JSON Backup Stores Raw Device-Local Media Paths
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:120-150`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L120-L150)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Exports literal path strings like `/data/user/0/app.notekar/app_flutter/audio_123.m4a`, which break when restoring onto another device.
- **Apple HIG / Fix:** Bundle backups into a `.notekar` ZIP archive containing `backup.json` alongside a `/media` subfolder, remapping paths on restore.

#### 101. Synchronous `File.lastModifiedSync()` in Backup File Sorting
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:180-210`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L180-L210)
- **Dimension:** Performance Optimization
- **Priority:** P1
- **Current Behavior:** Sorts backup files synchronously on the UI thread using repeated `lastModifiedSync()` calls.
- **Apple HIG / Fix:** Perform file sorting asynchronously during directory scan before populating state.

#### 102. Auto-Backup Lacks Rolling 30-Day Retention Pruning
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:240-270`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L240-L270)
- **Dimension:** Performance / Storage
- **Priority:** P2
- **Current Behavior:** Auto-backup creates a new file daily without ever purging old files, causing storage bloat over months of usage.
- **Apple HIG / Fix:** Implement a rolling retention policy: keep daily backups for 7 days, weekly for 4 weeks, monthly for 6 months, and delete older backups.

#### 103. Backup Filename Timestamp Uses Colons on Android
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:285-300`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L285-L300)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Filename is generated as `notekar_backup_2026-11-01_21:30:00.json`, which fails when shared to Windows or FAT32 external SD cards.
- **Apple HIG / Fix:** Sanitize timestamps to safe ISO format `notekar_backup_2026-11-01_21-30-00.json`.

#### 104. Backup Integrity Check Only Validates File Existence
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:310-330`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L310-L330)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** "Backup Health" reports OK if the file exists on disk, even if the file is zero bytes or truncated JSON.
- **Apple HIG / Fix:** Validate file integrity by verifying JSON root keys (`version`, `sessions`, `categories`) and payload checksum before reporting healthy.

#### 105. Restore Failure Displays Generic Error Without Diagnostics
- **Location:** [`lib/screens/home/home_backup_lifecycle.dart:340-360`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/screens/home/home_backup_lifecycle.dart#L340-L360)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Catches all exceptions during import and displays generic snackbar `"Restore failed"`.
- **Apple HIG / Fix:** Surface specific actionable causes: "Incompatible schema version", "File corrupted", or "Permission denied".

---

### Area 10: Localization, Directionality & Haptics (Items 106–112)

#### 106. String Interpolation Breaks ICU Dynamic Plural Lookups
- **Location:** [`lib/utils/l10n_utils.dart:120-150`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/l10n_utils.dart#L120-L150)
- **Dimension:** Functional / Localization
- **Priority:** P1
- **Current Behavior:** Plurals are generated using string interpolation like `"Every $days Days"`, which fails in Russian, Polish, and Arabic that have 3-5 distinct plural forms.
- **Apple HIG / Fix:** Refactor to standard ICU plural messages with zero, one, few, and many rules.

#### 107. Navigation Chevrons Fail to Mirror in RTL Locales
- **Location:** [`lib/utils/l10n_utils.dart:210-240`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/l10n_utils.dart#L210-L240)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Chevrons remain pointing rightward regardless of layout text direction.
- **Apple HIG / Fix:** Create a reusable `NkChevron()` widget that automatically flips along the horizontal axis when `Directionality.of(context) == TextDirection.rtl`.

#### 108. Asymmetric Hardcoded Paddings Break RTL Symmetry
- **Location:** [`lib/utils/l10n_utils.dart:310-340`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/l10n_utils.dart#L310-L340)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Cards specify `EdgeInsets.only(left: 16, right: 8)`, creating visual asymmetry in RTL mode.
- **Apple HIG / Fix:** Replace all directional paddings with `EdgeInsetsDirectional.only(start: 16, end: 8)`.

#### 109. Direct Platform Haptics Bypass User In-App Preference
- **Location:** [`lib/utils/app_utils.dart:90-115`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart#L90-L115)
- **Dimension:** Functional Enhancement
- **Priority:** P1
- **Current Behavior:** Over 14 dialogs directly call `HapticFeedback.lightImpact()` or `HapticFeedback.selectionClick()` from `flutter/services.dart`, ignoring `AppHaptics.enabled = false`.
- **Apple HIG / Fix:** Route all haptic triggers through `AppHaptics.light()`, `AppHaptics.selection()`, and `AppHaptics.medium()` so that user preference is strictly respected app-wide.

#### 110. Double-Beat Haptic Timer Fires Second Beat After Navigation
- **Location:** [`lib/utils/app_utils.dart:130-145`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart#L130-L145)
- **Dimension:** Functional Enhancement
- **Priority:** P2
- **Current Behavior:** Apple double-beat uses `Future.delayed(45ms)` without holding a cancellation token; if user pops the sheet, the second beat fires on the parent screen.
- **Apple HIG / Fix:** Add cancellation token to pending secondary haptic pulses.

#### 111. Clipboard Copy Operations Lack Tactile Confirmation
- **Location:** [`lib/utils/app_utils.dart:210-230`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart#L210-L230)
- **Dimension:** Functional Enhancement
- **Priority:** P3
- **Current Behavior:** Copying note text or diagnostics logs shows a snackbar but offers no tactile confirmation.
- **Apple HIG / Fix:** Fire `AppHaptics.successDouble()` when a copy action is committed.

#### 112. Monospace Digit Alignment Missing from Timeline Duration Chips
- **Location:** [`lib/utils/app_utils.dart:240-260`](file:///c:/Users/dheer/OneDrive/Documents/dv/Android%20Projects/Project%20YABP%20DigitalSuraksha/Notekar%20-%20Flutter/lib/utils/app_utils.dart#L240-L260)
- **Dimension:** Visual Polish
- **Priority:** P2
- **Current Behavior:** Duration badge texts (`00:04:12` -> `00:04:13`) shift their container widths due to proportional font glyph widths.
- **Apple HIG / Fix:** Introduce token `NkTextStyles.tabularMono` featuring `FontFeature.tabularFigures()`.

---

## Phased Implementation Roadmap

```
  +-----------------------------------------------------------------------+
  |              NOTEKAR WAVE 2 EXECUTION ROADMAP (112 ITEMS)              |
  +-----------------------------------------------------------------------+
     |
     +--> Phase 1: High-Risk Engine & Safety Invariants (Items 1-25)
     |    - Memory leaks: TapGestureRecognizer disposal, audio stream leaks
     |    - Main-thread I/O: statSync, lastModifiedSync, commit() -> apply()
     |    - Accidental data loss: Sobriety reset & backup deletion confirmation
     |    - Baseline unit test integrity: All 429 tests remain green
     |
     +--> Phase 2: Micro-Typography, Squircle Curvature & Touch Comfort (Items 26-55)
     |    - Markdown regex hoisting, italics, strikethrough, blockquotes
     |    - Continuous squircle geometry (NkRadii) across badges and cards
     |    - Expansion of touch hit targets to Apple HIG 44x44pt minimum
     |    - Tabular monospace numbers preventing duration jitter
     |
     +--> Phase 3: Timeline Physics, Gesture Ergonomics & Audio Ballistics (Items 56-85)
     |    - Logarithmic spring rubber-banding & velocity snap simulation
     |    - 2:1 horizontal slope lock preventing scroll arena collisions
     |    - Envelope follower physics (15ms attack / 120ms decay) for audio wave
     |    - Urge Surfing GPU layer migration (Transform.scale) & phase cross-fade
     |
     +--> Phase 4: Localization, Midnight Arithmetic & Backup Hardening (Items 86-112)
     |    - Cross-midnight session calculation (+1 day rollover) & DST safety
     |    - ICU plural resolution for non-English locales
     |    - RTL chevron and layout directional symmetry
     |    - Full schema CSV/JSON backup bundling (.notekar archive)
```

### Phase 1: High-Risk Engine & Safety Invariants
- **Target Items:** 1, 11, 16, 22, 23, 24, 25, 29, 32, 42, 45, 50, 58, 63, 65, 75, 77, 83, 84, 93, 94, 99, 100, 101, 104, 109.
- **Objectives:**
  1. Eliminate all UI-thread blocking operations (`statSync`, `lastModifiedSync`, `commit`).
  2. Plug gesture recognizer and timer memory leaks.
  3. Shield destructive actions (streak reset, backup delete, unconfirmed restore).
  4. Ensure all existing 429 unit tests pass without regression.

### Phase 2: Micro-Typography, Squircle Geometry & Touch Comfort
- **Target Items:** 2, 3, 4, 5, 6, 7, 8, 9, 10, 17, 19, 26, 30, 31, 33, 35, 36, 37, 39, 40, 41, 47, 48, 52, 53, 59, 67, 71, 76, 79, 85, 88, 89, 91, 92, 107, 108, 112.
- **Objectives:**
  1. Elevate typography to Apple HIG standards: tabular figures, optical bullet alignment, italic/strikethrough/blockquote formatting.
  2. Enforce continuous squircle curvature via `NkRadii`.
  3. Expand all interactive hit targets to minimum 44x44pt bounding boxes.

### Phase 3: Timeline Physics, Gesture Ergonomics & Audio Ballistics
- **Target Items:** 12, 13, 14, 15, 18, 20, 21, 38, 43, 44, 46, 51, 54, 66, 72, 81, 82, 86, 90, 95, 96, 97, 110, 111.
- **Objectives:**
  1. Implement authentic Apple spring physics on swipeable cards and sheet pulls.
  2. Resolve gesture arena conflicts between horizontal card swipes and vertical list scroll.
  3. Upgrade audio visualizer to real amplitude decibel scaling with ballistic envelope follower physics.
  4. Optimize Urge Surfing rendering onto GPU layer via `Transform.scale`.

### Phase 4: Localization, Midnight Arithmetic & Backup Hardening
- **Target Items:** 27, 28, 34, 49, 55, 56, 57, 60, 61, 62, 64, 68, 69, 70, 73, 74, 78, 80, 87, 98, 102, 103, 105, 106.
- **Objectives:**
  1. Support cross-midnight sessions (+1 day rollover) in manual entry, smart trim, and interval ledger.
  2. Implement ICU pluralization and RTL directional mirroring.
  3. Package backups into robust `.notekar` archives with media bundling and schema validation.
  4. Add emergency launcher shortcuts and Android 12+ Monet dynamic theming.

---

## Verification & Architecture Consistency Rules

1. **Test Suite Invariant:**  
   Every phase must begin and terminate with a clean execution of `flutter test` in `Notekar - Flutter`. No test may be skipped or disabled.
2. **AppHaptics Centralization:**  
   Direct calls to `HapticFeedback` from `flutter/services.dart` are prohibited in UI components. All haptics must route through `AppHaptics` in `lib/utils/app_utils.dart` to respect user settings.
3. **Design System Adherence:**  
   Components must use `NkButton`, `NkRadii`, and `spacing*` design tokens. Ad-hoc raw `ElevatedButton`, `BorderRadius.circular(x)`, and magic layout numbers are disallowed.
4. **Non-Blocking I/O Guarantee:**  
   No `Sync` filesystem methods (`statSync`, `readAsStringSync`, `lastModifiedSync`) may execute on the Flutter main UI isolate or Android main thread.

---

## Remaining Questions & Gaps

1. **Android Monet Dynamic Colors on Pre-API 31 Devices:**  
   How should the home screen widget render on Android 10 and 11 devices that do not support Monet dynamic color attributes? Recommended fallback: retain NoteKar's signature OLED pitch black (`#121212`) and emerald theme.
2. **Backward Compatibility of `.notekar` Backup Archives:**  
   When migrating to ZIP archives containing audio memo files, older versions of NoteKar will only expect raw `.json`. The import flow must retain fallback support to parse legacy raw JSON backups seamlessly.
3. **External SD Card Timestamp Formatting:**  
   While changing `:` to `-` in backup filenames solves Android SD card writing errors, existing local backups named with `:` must still be discoverable by the local backup scanner.
