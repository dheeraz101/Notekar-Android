# NoteKar UI/UX follow-up audit

Date: 2026-10-23  
Scope: History filter discoverability, Settings destination/control inventory, and accessibility/layout evidence.  
Source checkout: `Notekar - Flutter`.

## History filter change

The pinned History filter strip previously put eight filters plus Advanced in one horizontal scroller beside a scroll-to-top button. On a phone, Checkpoints could be partly hidden and users had no clear cue that more filters were off-screen.

The strip now keeps **All**, **Sessions**, and **Singles** as the visible primary choices and adds a fixed **More filters** control. The expanded filter sheet includes Today, This Week, Checkpoints, Grouped, and the other filters; its chip label reflects a selected secondary filter. Filter chips now expose button and selected-state semantics. The `All` choice remains a one-tap reset.

Source: `lib/dialogs/history_dialog.dart`, `lib/widgets/common_elements.dart`, and `lib/utils/l10n_utils.dart`.

## Settings destination inventory

This is a source inventory of routes and controls. It is not a claim that every control was physically tapped during this pass.

| Destination group | Routes / destinations | Main interactive controls and actions |
|---|---|---|
| Root and search | Settings root, Search, Search Notes | Open destination rows; search settings, recent searches, clear search/history, open results; search-result switches can be changed in place. |
| Identity | Personal Profile | Edit profile details and birth date; save profile. |
| Appearance | Personalization, Accent Color, Display, App Icons, Language | Select theme, accent, icon, language; adjust clock/time format, seconds, typography, labels, image behavior, control sizing, toolbar, motion, translucency, saved hint. |
| Logging and capture | Logging, Capture | Choose default mode and tap delay; configure persistent controls, quick-note behavior, post-unlock logging/action, and checkpoint visibility on Home/History. |
| History and records | Moments, Activity Tags / Quick Tags, Modes & Categories, Targets & Projects, Dashboard, Life Audit, Sobriety Companion | Confirm-delete and image/number/count options; add/edit/delete/reorder tags; add/edit/reorder modes/categories; create and manage goals, projects and milestones; adjust time estimates and audit period; enable/configure sobriety. Destructive actions have confirmation flows. |
| Reminders | Reminders, Time Reflection, Reminder Message | Daily/inactivity/weekly/monthly reminder toggles and schedule/message controls; reflection interval and alert; permission and battery-optimization actions; edit and save reminder text. |
| Privacy and security | Privacy & Security, App Lock, Configure Lock, Security & Privacy details | Hide content; enable/disable lock; choose system lock or in-app PIN; configure/reset credentials and lock timing. Credential and lock behavior was not exercised in this layout pass. |
| Data | Data & Backup, Backup & Export, Backup Status, Local Backups, Trash Bin | Export CSV/JSON/Markdown/calendar; create/import/delete backups; inspect status and health; restore or permanently delete records. These actions were not triggered. |
| Updates and information | Updates & Notices, Update Center, Changelog, Commits, Official Bulletins, About, Help & Guides, App Philosophy, Upcoming Features, Feedback, Legal, Licenses | Choose update channel/download behavior, inspect notices/build information, open documentation and legal text, and submit/open support destinations. External links and update/install actions were not triggered. |
| Advanced and diagnostics | Advanced, Accessibility, Developer Options, Reset, God Mode, Diagnostics, Device Health, Network Monitor, Trigger Analysis, Integrations & Automation | Language and accessibility preferences; haptics/sound/reduced motion/large text/high contrast; automation and broadcast API; diagnostics and exports; reset settings/data/factory reset. Reset and developer actions were not triggered. |

### Toggle inventory found in the source

These are the `SettingsSwitchRow` controls found by static inspection. Their callbacks are wired in the corresponding page and `settings_dialog.dart`; callback wiring does not prove persistence or device behavior.

There are **50 switch-row call sites** and **118 action-row call sites** in `lib/dialogs/settings/`. The two search-page switch-row call sites render matching settings results/recent searches; they are not additional preference definitions.

- **Accessibility / Advanced:** Sound Effects; Reduced Motion; Large Text; High Contrast Mode.
- **App Lock:** App Lock.
- **Capture:** Note on Click; Log after unlock; Show Habits on Home Canvas; Hide Habits from Main Timeline.
- **Display:** Show Seconds; Highlight Seconds; Button Labels; History Text; Show Images Always; Large Controls; Toolbar Backplate; Live Icon Motion; Enable Translucency; Last Saved Hint.
- **Integrations:** Enable Broadcast API.
- **Logging:** Persistent Control; Quick Note Popup; Rainbow Cards; (plus mode, delay and selection controls rendered in other controls).
- **Modes & Categories:** Adaptive Color; Default Mode on App Close.
- **Moments:** Confirm Delete; Show Images Always; Use Numbers in Single; Reset Daily; Enable Count on Save; Minimal Moment Options.
- **Privacy & Security:** Hide App Content.
- **Reminders:** Daily Reminder; Inactivity Reminder; Weekly Reminder; Monthly Reminder.
- **Sobriety:** Enable Sobriety Mode.
- **Targets & Projects:** Session Reflection; Milestone Celebration; Daily Deficit Pacing; Auto-Tag Attribution; Exclusive Session Locking; Floating Dynamic Island.
- **Time Reflection:** Enable Time Reflection; Sound & Chime Alert.
- **Update Center:** Auto-Download Updates; Rm -rf Cache; App Notices.

### Action-row title inventory found in the source

The following action rows open pages, dialogs, pickers, exports, confirmations, permissions, or external destinations. Their precise action can depend on callback state; names below preserve the visible source titles and dynamic labels.

- **Advanced:** Language; Accessibility; Automation; Developer Options; Factory Reset; God Mode; Circuit Breakers; Export Diagnostic Logs; language choices; haptic-style choices; Reset Settings; Reset All Data; Factory Reset.
- **App Lock:** Configure Lock; Reset PIN Lock; lock-delay choices; System Lock; In-App PIN.
- **Capture:** Single; Two-Way; Last Used; Notification Alert; Floating Note Overlay.
- **Data & Backup:** Backup & Export; Backup Status; Export CSV; Export Last 7 Days; Export JSON; Export Journal (.md); Export Calendar (.ics); Export Backup; Import Backup; Local Backups; Migrate from Other Apps; Android Backup; Data Health; Encrypted Backup; Google Drive Backup.
- **Feedback / release notes:** Report a Bug; Request a Feature; Full Release Archive on Web.
- **God Mode:** Matrix Phosphor Terminal; Kindle E-Ink Paperwhite; God Mode Icon; Revoke God Mode.
- **Help & Guides / About:** App Philosophy; Guides; Help; Upcoming Features; Licenses; Terms of Use; Privacy Policy.
- **Integrations & Automation:** Log Moment Intent; Quick Log; Check-In & Out; Draft Note; Open Screen; Text Selection Menu; Share Target.
- **Logging navigation:** Dashboard; Life Audit; Capture; Moments; Modes; Targets & Projects; Activity Tags; Reminders; Backup & Export; Trash Bin; Sobriety Companion; Timer Concurrency; Daily Wrap-up.
- **Moments:** Search Notes.
- **Modes & Categories:** dynamic category rows.
- **Personalization:** Display; Accent Color; App Icons.
- **Privacy & Security:** Safety Verified; No Analytics; Network Use; App Lock.
- **Reminders:** Time; Message; Mindfulness; Remind If Inactive For; Days of Week; Day of Month.
- **Sobriety Companion:** Reset Streak to Now; Trigger Analysis; Set Sobriety Start Date; Theme Style; View All Milestones; dynamic theme choices.
- **Targets & Projects:** Single Tap; Double Tap.
- **Time Reflection:** Reminder Interval; Message; Test Alert; Start Time; End Time.
- **Update Center:** Stable Build; Beta Build; Experiment Channel; Software Update; Build Channel; Official Bulletins; What's New; Changelog.
- **Search results:** dynamic result titles and recent-search terms navigate to the matching setting/action.

Other interactive controls include navigation/action rows, segmented theme/time-format selectors, sliders/steppers, date/time pickers, text fields, tag/mode CRUD dialogs, reorder handles, confirmation dialogs, permission buttons, backup import/export buttons, and external links. A complete behavior matrix requires walking each destination with a fresh UI build and recording before/after state; this pass did not mutate settings to simulate every action.

## Accessibility and layout checks performed

Test target: Android emulator `emulator-5554`, installed app build already present before the current source edits. The physical phone was left untouched for this layout check.

- **Narrow screen + larger system text:** temporarily set emulator display to 800 × 1800 and system font scale to 1.3. Settings root rows grew to fit and wrapped without visible overlap; the profile subtitle truncated with an ellipsis. System font scale and display size were restored to 1.0 and 1080 × 2424.
- Screenshot captures are in `.artifacts/ui-narrow.png` and `.artifacts/ui-search.png` (the latter shows the keyboard-open state).
- **Keyboard open:** opened Settings search without entering text. The search field remained visible above the keyboard and the sheet adjusted its height. The accessibility tree exposed an `EditText` with hint `Search settings`. No query was entered, so recent-search data was not changed.
- **Landscape:** attempted both landscape display sizing and Android user rotation on the emulator. Its window remained at `ROTATION_0`, 1080 × 2424, so landscape rendering is **not verified**. Rotation settings were restored to their original values.
- **TalkBack:** not enabled. XML accessibility hierarchy was inspected without changing the accessibility service. Existing rendered `SettingsSwitchRow` nodes on the installed build appeared clickable but not checkable; the current source has been changed to add state semantics centrally, but that change could not be built and checked on-device yet.

### Build and verification limitation

`flutter analyze --no-pub` did not produce output within 60 seconds; it was interrupted. A subsequent `flutter build apk --debug --no-pub` also produced no output for over 150 seconds and was interrupted; the existing APK remained unchanged (last modified 2026-10-08). The spawned Dart/Java processes remained in the OS process list, so they were not killed. Consequently, the History change and prior UI source changes have not been compiled, installed, or validated on the device. `git diff --check` completed without whitespace errors. Do not mark the code changes device-verified until a successful build and a fresh install/retest.

## Remaining UI gates

1. Build and install the current source, then verify History primary filters, More filters sheet, selected-state announcement, Checkpoints and Grouped choices, and reset to All.
2. Recheck Settings switch semantics after the centralized source change; listen with TalkBack to focus order and the role/value/state of switches, chips, and icon-only actions.
3. Repeat settings/profile, tag, reminder, and checkpoint page layout at OS font scale 1.3+, narrow width, landscape, and keyboard open; record screenshot and any overflow.
4. Walk every Settings destination and tap each non-destructive control; record expected/actual state and persistence. Do not trigger reset, destructive deletion, PIN changes, actual notification delivery, external purchase/support links, or update installation during this inventory pass.
5. Re-run the same key screens on the physical Android phone after the build. No iOS behavior can be certified from these Android checks.
