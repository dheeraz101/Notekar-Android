## NoteKar v7.5.14 (build 26BR1108)

Signed release — built automatically from the branch.

### What's New & Highlights

- **Classic iOS Custom Switch Toggles**: Restored the beloved classic iOS toggle geometry from commit 7.5.11 (62×32 track, 34×28 pill thumb, +10px fluid mechanical stretch, soft drop shadow, and official Apple HIG '|' and 'O' accessibility indicators). Tapping anywhere on the settings row fluidly elongates the thumb, and switch states strictly mirror parent permissions with zero desynchronization or stuck visuals on cancelled PIN prompts.
- **Habit Live Sessions & Reverse Countdown**: Start live sessions from routine habits with 15m, 30m, 45m, or custom duration targets. The home screen chronometer counts down in reverse towards completion, accompanied by a dedicated Apple HIG stop action, high-contrast canvas text rendering, and automatic return to neutral default mode when the session concludes.
- **Permanent Session Merging & Mode Switching**: Seamlessly merge individual timestamps into structured IN/OUT focus sessions directly from your History timeline. Merged sessions now persist permanently in SQLite across sheet reloads and restarts, with instant reclassification to Work, Deep Focus, or General Mode without reverting or breaking pairing.
- **Hierarchical Settings Navigation & Predictive Back**: Deeply nested settings subpages now remember their lineage. Swiping from the screen edge or tapping the back button ascends smoothly to the immediate parent category (e.g. Moments, App Lock, Developer Options) rather than abruptly collapsing to root settings, fully integrated with Android 14/15 predictive back gestures.
- **Apple HIG & BitChord Precision Design System**: Elevated visual harmony featuring continuous 60.7% squircle corner smoothing, positive SF Pro micro-typography tracking (+0.05 to +0.2), redesigned full-width Data Safety and App Permissions cards, and sleek minimal Content Rating scorecard badges.
- **1-Month Beta Milestone & Gated Experimental Builds**: Dedicated beta testers who use NoteKar continuously for 30 days receive an authentic Apple HIG milestone popup unlocking early access to Developer Experiments. Testers with God Mode unlocked can also reveal experimental builds instantly with a single tap.
- **Timeline Rich Markdown & Expandable Notes**: Express ideas naturally with inline bold, italic, code blocks, blockquotes, and bulleted lists rendered directly on timeline cards. Extended thoughts feature an intuitive "Show more / Show less" expansion toggle and debounced 120Hz audio scrubbers.
- **Hardened Zero-Knowledge Vault (100k PBKDF2 Iterations)**: Vault key derivation upgraded to OWASP-standard 100,000 PBKDF2 iterations for impenetrable on-device encryption. Note drafts now auto-save continuously to prevent lost reflections, paired with dynamic recent-apps window obfuscation.

### Key Improvements & Fixes
- **App Lock Safeguard**: Resolved optimistic switch stickiness by binding switch states directly to verified controller values. Canceling biometric/PIN setup leaves toggles strictly in their OFF state.
- **Habit Canvas Clean-Up**: Completed checkpoints maintain their distinctive category colors rather than turning blue. Long-pressing the Habits title pill opens Settings -> Logging -> Capture and auto-scrolls to the home canvas toggle.
- **Factory Reset Polish**: Removed redundant Zero-Knowledge notice container from all factory reset dialogs for a cleaner Apple HIG dialog layout.
- **Performance & Motion**: 120Hz Vsync Ticker parallax tilt interpolation with automatic lifecycle suspension to preserve battery.
