## Notekar v7.5.11 (Beta Release)

> *App-Aware Floating Control Pill, Edge Line Handle Docking, Oceanic Fluid Sanctuary, Peer Horizon QR Pass & Camera Scanner.*

### What's New

- **App-Aware Floating Control Pill & Edge Line Handle Docking**:
  - **Foreground Auto-Hide**: The floating timer overlay automatically hides while NoteKar is open on screen, keeping the app UI clean and unobstructed.
  - **Seamless Background Reappearance**: Overlay automatically restores when NoteKar is minimized or the user navigates to the home screen or other apps.
  - **Slim 5dp Vertical Edge Handle**: Tapping **"✕ Hide"** on the Apple HIG expanded card docks the pill into a slim 5dp vertical handle touching the screen bezel (`32dp` ergonomic touch target).
  - **Tactile Gesture Restoration**: Tapping the edge line springs the orb back with elastic overshoot bounce; swiping inward (>12dp) seamlessly drags out the circular orb with magnetic edge snapping.
  - **Session-Harmonized Glow**: Edge handle borders and grip indicator dynamically reflect active (emerald), paused (amber), or idle (subtle slate) timer states.

- **Living Oceanic Fluid Sanctuary & Crowned Queen Fish (Accent Color Overhaul)**:
  - **Full Edge-to-Edge Waves**: Removed rigid card boundaries; fluid wave meniscus now flows edge-to-edge directly across the page.
  - **Crowned Queen Fish**: Selected accent is crowned Queen Fish at deep waters (`targetY = 660`) with an enlarged commanding scale (`1.38x`) and a dorsal-aligned 3-pointed golden crown (`#FFD700`).
  - **19 Companion Fish**: Varied scales (`0.72x`–`0.92x`) swimming gracefully across shallow and mid-depth levels with harmonic wave propulsion.
  - **Theme-Adaptive Abyssal Lighting**: Dark theme renders abyssal depth shadows and volumetric rays; Light theme renders crystalline sunlit wave sheens.
  - **Faceted Riverbed Rocks**: 7 realistic organic stones rendered strictly in NoteKar's fixed invariant UI colors (red, orange, green, grey, ink, white, gold).

- **Peer Horizon QR Pass & Fullscreen Camera Scanner**:
  - **Minimal Sovereign QR Pass**: Redesigned Share Identity Card to present a clean, high-contrast Apple HIG QR pass with zero extraneous chronometer clutter.
  - **60fps Moving Laser Reticle**: Continuous emerald laser sweep animation across the viewfinder reticle with torch and gallery fallback controls.
  - **Animated Visual Scan Feedback**: Instant central emerald checkmark HUD on valid scan; animated red error badge on unrecognized QR with auto-reset.

- **Peer Horizon Comparison Engine**:
  - **Side-by-Side Benchmarking**: Deep comparative sheet analyzing conscious time, waking weeks, sobriety streaks, and 24-hour life balance between self and peer.
  - **Single-Peer Conflict Safeguard**: Enforces a single active saved peer policy with replace, view-only, or cancel resolution.

### Improvements & Polish

- **Update Center Layout**: Cryptographic description now occupies full card width below build cache metrics for comfortable reading.
- **App Icons Page**: Added responsive Wrap header layout and launcher instructions, eliminating text clipping on small screens and large text scales.
- **Sandboxed Media Storage**: Captured photos in timeline are persisted to sandboxed app directory, fixing missing thumbnails in history sheet.
- **Resilient Database Healing**: Automated database self-healing checks to detect, recover, and safeguard against data corruption.

### Bug Fixes

- Fixed floating overlay flashing over NoteKar on startup.
- Fixed species counter collision on narrow viewports with ellipsis handling.
- Resolved history sheet photo thumbnail loading issue.
- Fixed `scripts/update-version.ps1` prerelease parsing and universal version string replacement.

### Integrity

- **Build Tag**: 26BR1025 (version 7.5.11+26102501)
- **Release Track**: Beta Release (BR)
- **Automated Tests**: All unit & widget tests passing (0 failures, 0 lints)
