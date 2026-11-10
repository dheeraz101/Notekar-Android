---
description: Mandatory standards for Apple Human Interface Guidelines visual elegance, squircle tokens, typography, and haptics
globs: lib/widgets/**/*.dart, lib/dialogs/**/*.dart, lib/theme/*.dart, lib/screens/**/*.dart, android/app/**/QuickNoteActivity.kt
---

# 03 - Apple HIG UI Consistency Standard

## 1. Design Token System
All visual surfaces must derive exclusively from NoteKar's canonical design system (`NkTokens` / `app_tokens.dart` / `Palette`):

### 1.1 Geometry & Curvature
- **Cards & Grouped Sections**: Use `NkRadii.card` (`16pt` radius) or `ContinuousSquircleBorder(borderRadius: BorderRadius.circular(24.0))`.
- **Modal Sheets & Dialogs**: Use `NkRadii.sheet` / `NkRadii.dialog` (`28pt` continuous squircle curvature).
- **Interactive Badges & Pills**: Use `NkRadii.pill` (`999.0pt`).
- Never use raw sharp corners or non-standard border radius values (e.g. `BorderRadius.circular(10)`).

### 1.2 Spacing & Layout
- Use `NkSpacing`:
  - `xxs` (2pt), `xs` (4pt), `sm` (8pt), `md` (12pt), `lg` (16pt), `xl` (20pt), `xxl` (24pt), `xxxl` (32pt).
- Canonical screen horizontal margin: `NkSpacing.screenGutter` (`16pt`).
- Canonical card internal padding: `NkSpacing.cardPadding` (`horizontal: 16pt, vertical: 14pt`).
- Canonical divider indent: `54pt` to `56pt` (aligning with leading icon title content).

### 1.3 Typography Scale
- Primary font: **Inter** with proportional optical tracking matching Apple SF Pro:
  - `largeTitle` (34pt, w800, -1.3 tracking)
  - `title1` (28pt, w700, -0.8 tracking)
  - `title2` (22pt, w700, -0.6 tracking)
  - `title3` (20pt, w600, -0.5 tracking)
  - `headline` (17pt, w600, -0.4 tracking)
  - `body` (17pt, w400, -0.3 tracking)
  - `callout` (16pt, w400, -0.3 tracking)
  - `subheadline` (15pt, w400, -0.2 tracking)
  - `footnote` (13pt, w400, -0.1 tracking)
  - `caption` (12pt, w500, 0.0 tracking)
- **Tabular Figures**: All timestamps, chronometers, stopwatches, numeric stats, and countdowns MUST use OpenType tabular figures (`FontFeature.tabularFigures()` or `.withTabularFigures()`) to prevent number jitter during increments.

### 1.4 Haptic Feedback & Motion
- All primary button taps, tag toggles, and mode selections must trigger subtle haptic feedback:
  - Mode toggle / chip selection: `HapticFeedback.selectionClick()`
  - Primary logging / action: `HapticFeedback.mediumImpact()`
  - Destructive action: `HapticFeedback.heavyImpact()`
- Animations must use Apple standard cubic curves:
  - `NkCurves.appleEase` (`Curves.easeInOutCubic`)
  - `NkCurves.appleSpring` (`Cubic(0.25, 0.9, 0.35, 1.0)`)
  - Durations: `150ms` (fast micro-interaction) to `250ms` (snappy dialog entrance).
