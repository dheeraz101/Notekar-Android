## Notekar v7.3.2

Signed release - built automatically from the branch.

### What's New

- **Redesigned Compact History Mode (Life Ledger High-Density View)**:
    - Ultra-dense timeline layout presenting 2x–3x more moments with scaled rail markers and micro
      duration badges.
    - Automatic suppression of empty note placeholder boxes in compact mode to maximize vertical
      density.
    - Scaled duration connector badges (9.5pt) and start/end time markers (12pt) with tabular
      numerical figures for perfect vertical scanning alignment.
- **Unified Apple HIG Dialog Architecture (`CupertinoAlertDialog`)**:
    - Re-engineered all multi-choice confirmation dialogs across NoteKar to native iOS
      `CupertinoAlertDialog` presented via `showCupertinoDialog`.
    - Zero button label truncation guarantee across all device viewports with automatic Apple HIG
      vertical action stacking.
    - Native Cupertino External Navigation security alert featuring verified domain badges and
      destination URL previews.
    - Native Cupertino Network Warning modal featuring animated check toggles and download size
      indicators.

### Improvements & Polish

- Refined day section header spacing in `HistoryDialog` when compact history is toggled, matching
  timeline density.
- Enhanced tactile haptic feedback patterns across all confirmation dialogs (
  `NotekarHaptics.selection`).
- Full automated test suite coverage for compact timeline cards, empty note omission logic, and
  Cupertino alert rendering.

### Security and Integrity

NoteKar binaries undergo automated compilation and scanning.

- **VirusTotal Report**: https://www.virustotal.com/gui/file/placeholder
