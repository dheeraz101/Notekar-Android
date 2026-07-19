# Settings HIG Refinement & Beta Info Plan

This plan further refines the Settings hierarchy by reintroducing clean subtitles for sub-pages and adding a high-fidelity "Beta" information experience to the Device Health section.

## Proposed Changes

### 1. Subtitle vs. Footer Logic (Apple HIG)
- **Goal:** Differentiate between immediate context (subtitles) and explanatory details (footers).
- **Sub-pages:** Reintroduce a clean, icon-less subtitle directly beneath the large titles for pages like Display, Logging, etc.
- **Main Settings:** Keep the description at the bottom as a footer with the info icon, as it provides overall app context.
- **Action:**
    - [NEW] Create `SettingsPageSubtitle` widget: 15px, `text2` color, no icon, minimal padding.
    - [MODIFY] Update `SettingsDialog` sub-pages to use this subtitle instead of (or in addition to) the footer.

### 2. Device Health Layout Overhaul
- **Goal:** Prioritize the Adaptive Engine status over technical diagnostic rows.
- **Order:**
    1. Adaptive Engine Info Card (Top).
    2. Diagnostic Rows Group.
    3. Page Footer Description.
    4. Beta Info Block.

### 3. Beta Information & "Learn More"
- **Goal:** Add a professional beta disclosure with an interactive explanation.
- **Action:**
    - [NEW] Add a Beta Info block using the info-icon style in the Device Health page.
    - [Interaction:] "Learn More" link triggers a clean `AppSheet` popup.
    - [Content:] "What to expect from NoteKar Beta" — focusing on stability, feedback, and private data handling in Apple's "human" style.

## Component-Specific Tasks

### [MODIFY] [settings_widgets.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/widgets/settings_widgets.dart)
- [NEW] `SettingsPageSubtitle` widget.
- Refine `SettingsPageDescription` padding for footer use.

### [MODIFY] [settings_dialog.dart](file:///C:/Users/dheer/OneDrive/Documents/dv/Android Projects/Project YABP DigitalSuraksha/Notekar - Flutter/lib/dialogs/settings_dialog.dart)
- Reorganize `_deviceHealthPage`.
- Add `_showBetaInfoPopup` method.
- Update sub-page builders to use `SettingsPageSubtitle`.

## Verification Plan

### Manual Verification
- **Visual Audit:** Check that subtitles appear clean and aligned under Large Titles.
- **Order Check:** Confirm Device Health starts with the Adaptive Engine card.
- **Beta Interaction:** Tap "Learn More" and verify the popup is clean and button-less (icon close only).
- **HIG Consistency:** Ensure the main settings footer remains distinct from the sub-page subtitles.
