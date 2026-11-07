# NoteKar v7.5.13 Release Notes

> **Version:** 7.5.13  
> **Build Number:** 26BR1107 (versionCode 26110701)  
> **Release Date:** November 7, 2026  
> **Channel:** Beta Preview & Release Candidate  
> **Architecture:** Sovereign Offline-First, Local Isar Encryption, Zero Telemetry  

---

### What's New & Major Highlights

#### 1. Classic iOS Custom Switch Toggles (Commit 9a166b26 Restoration)
- **Authentic Geometry & Aesthetics**: Restored the beloved classic custom iOS switch toggle with 62x32 track, 34x28 white pill thumb, and tactile drop shadow.
- **Fluid Mechanical Stretch**: Thumb dynamically elongates (+10.0px) along the travel axis during tap-down or drag gestures, communicating physical momentum.
- **Apple HIG Accessibility Indicators**: High-contrast active '|' bar (Alignment(-0.58, 0)) and inactive 'O' ring (Alignment(0.72, 0)) embedded within the track.
- **Interactive Drag Gestures**: Full horizontal dragging with 400px/s velocity fling snapping, haptic resonance, and touch-down state reconciliation.

#### 2. Hierarchical Settings Back-Navigation (Tier-by-Tier Ascension)
- **Full 3-Tier Navigation Stack**: Replaced flat navigation with an intelligent navigation stack (_categoryStack, _getAncestors, _getParentCategory).
- **Seamless Upper-Page Popping**: Tapping Back or performing an edge-swipe gesture in any in-depth page (e.g., Display, Search Notes, Local Backups, Configure Lock, Time Reflection, Network Monitor) ascends to its immediate parent category rather than abruptly collapsing to the root settings screen.
- **Android System Back & Predictive Gesture Support**: System back gestures (handlePopRoute) and edge-swipe gestures ascend strictly one tier at a time with smooth transitions.

#### 3. Apple HIG & BitChord Precision Design System
- **Continuous Squircle Tokens**: Replaced circular tangent approximations with continuous Bezier curves (60.7% corner smoothing), eliminating the 'hard shoulder' where rounded corners meet straight edges.
- **SF Pro Micro-Typography Tracking**: Positive letter-spacing (+0.05 to +0.2) applied across small body text (<20pt), restoring crisp legibility on high-DPI Android displays.
- **Lifted Pill Segmented Controls (NkPillSegmentedControl)**: Dynamic sliding pill with adaptive accessibility font scaling up to 200% and infinite-width layout protection.
- **De-Pilled Action Buttons (NkButton)**: Removed forced 999dp pill radii on dialog action and confirmation buttons, restoring structured squircle geometry.
- **Single-Pass Damped Springs**: Tuned motion physics (damping ratio 0.72 - 0.78) eliminating exaggerated multi-bounce animations.

#### 4. Routine Habit Checkpoints & Consistency Dashboard
- **Universal Habit Management**: Edit or delete any habit checkpoint (including default routines) directly from the quick bar or consistency dashboard with confirmation sheets.
- **Dynamic Category Authoring**: Add, rename, or customize categories with dedicated Apple HIG color palettes and custom emojis, with automatic migration across all matching moments and presets.
- **Streak & Milestones Safeguards**: Reset actions protected with warning sheets and tactile haptics.

#### 5. Timeline Rich Markdown & Expandable Note Cards
- **Inline Markdown Rendering**: Formatted bold, italic, code, strikethrough, blockquotes, hashtags, and bullet lists directly rendered on timeline cards without raw syntax clutter.
- **Expandable Notes ('Show more / Show less')**: Long notes gracefully truncate with an inline expansion toggle, automatically resetting when edited.
- **Debounced Audio Scrubber**: 50ms seek debouncing delivers fluid 120fps playhead tracking during scrubbing.

#### 6. Zero-Knowledge Vault Hardening & Security Standards
- **OWASP PBKDF2 100k Iterations**: Default key derivation work factor upgraded from 10,000 to 100,000 iterations with header metadata backward compatibility.
- **Note Composer Draft Protection**: Automatic auto-saving to local storage with PopScope discard confirmation guards.
- **Dynamic Obfuscation Hook**: Native setWindowObfuscation MethodChannel hook for real-time window snapshot privacy.

#### 7. Android 14/15 System Parity & Modern Platform Integrations
- **Themed Monochrome Adaptive Icons**: Added <monochrome> icons and android:roundIcon attribute for Material You dynamic theming.
- **120Hz Vsync Parallax Motion**: Hardware-synced Ticker motion interpolation with automatic lifecycle pause when backgrounded.
- **Overlay Permission Auto-Resumption**: Seamlessly starts floating bubble service upon returning from Android system settings.

#### 8. Functional Intelligence & Analytics
- **Duration-Weighted Time-Slot Bias**: Morning, Afternoon, Evening, and Night bias calculations with cross-midnight interval slicing.
- **GPU-Accelerated Heatmap CustomPainter**: Collapsed 425 nested widgets into a single high-performance _AnnualHeatmapGridPainter.

---

### Integrity & Verification
- **Automated Tests**: 513 unit and widget tests passing (100% green across 272 test suites)
- **Static Analysis**: Zero errors, zero warnings, zero lints (flutter analyze)
- **Code Hygiene**: 100% formatted with dart format
- **Sovereign Standard**: 100% offline, zero cloud reliance, local Isar encryption
