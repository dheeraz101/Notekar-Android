## Notekar v7.5.3

Signed release — built automatically from the branch.

### What's New

- **Apple HIG Dark Theme Harmony & Surface Layering**: Monotonic Apple HIG Gray surface hierarchy
  across canvas (`#000000`), modal sheets (`#1C1C1E`), elevated cards (`#2C2C2E`), and controls (
  `#3A3A3C`). Synchronized `Glass` base surface and resolved pinned timeline header background
  mismatch.
- **Auto-Collapsing Dynamic Header Capsule**: 320ms spring physics curve (
  `spring(stiffness: 300, damping: 28)`) auto-collapsing the dynamic capsule back to its 32px
  resting pill on canvas touch or timeline scroll for an uninterrupted, immersive clock canvas.
- **Swiss Horology Detent Haptics**: Subtle audio-tactile click (`HapticFeedback.selectionClick()`)
  when swiping between Single and Two-Way logging modes at the 50% threshold, simulating a
  mechanical Swiss watch crown.
- **Smart Timeline Gap "Claim as Rest" Quick-Action**: One-tap "Rest" button on gap cards $\ge 15$
  minutes, converting empty void intervals into conscious restorative moments with instant undo
  support.
- **Live Ambient Radial Glow**: Soft 8% radial ambient glow behind the complication capsule matching
  the active category mode color.
- **Liquid Glass Optics & BitChord Aesthetics**: Apple HIG Liquid Glass styling with TopFadeBlur
  gradients and BitChord visual harmony.

### Improvements

- **Retrospective Session & Manual Entry Parity**: Complete support for retrospective Single and
  Two-Way logging with inline custom mode creation and zero yellow underline artifacts across time
  pickers.
- **Elevated Control Pills & Visible Borders**: Crisp 0.6px Apple hairline separators on cards and
  search inputs, paired with elevated segment pills for filters and dialogs.

### Bug Fixes

- **Rendering Pipeline & GPU Hardening**: Hardened Android GPU rendering pipeline, eliminating
  startup green screen glitches.
- **Active Session End Lifecycle**: Fixed end-button state transitions and timing intervals during
  live session mode switching.

### Integrity

- **Build Tag**: 26BR0923 (version 7.5.3+26092301)
- **Automated Tests**: All 201 unit & widget tests passing (0 failures, 0 lints)
- **Architecture**: 100% offline-first, zero telemetry, local sandboxed storage
