# Workflow 03: UI/UX & Apple HIG Review

> **Command**: `/hig-review`  
> **Objective**: Review, audit, and refine user interface surfaces to ensure strict alignment with NoteKar's Apple HIG design tokens, Android native interaction conventions, and accessibility guidelines.

---

## 1. Preconditions
- The target screen, dialog, or component file is identified.
- The project compiles without syntax errors.

---

## 2. Review Gauntlet (Step-by-Step)

### Step 1: Geometry & Squircle Curvature Audit
- Check corner radii against `NkRadii`:
  - Cards, inset grouped sections, and containers must use `NkRadii.card` (`16pt`) or `ContinuousSquircleBorder(radius: 24pt)`.
  - Bottom sheets, modal pickers, and confirmation dialogs must use `NkRadii.sheet` / `NkRadii.dialog` (`28pt`).
  - Chips, status capsules, and segmented pill backgrounds must use `NkRadii.pill` (`999pt`).
- Flag and replace any raw `BorderRadius.circular(8)` or `10` or `12` with proper `NkRadii` tokens.

### Step 2: Spacing & Alignment Audit
- Verify horizontal screen gutters match `NkSpacing.screenGutter` (`16pt`).
- Verify grouped section dividers use standard `dividerIndent` (`54pt` to `56pt`), properly aligning under title text rather than full-width.
- Ensure consistent vertical rhythm: `NkSpacing.sm` (8pt), `NkSpacing.md` (12pt), `NkSpacing.lg` (16pt), `NkSpacing.xl` (20pt).

### Step 3: Typography & Tabular Figures Audit
- Verify all text styles derive from `NkTypography` with Inter font family.
- Check tracking: Confirm negative letterSpacing on titles (`largeTitle`: -1.3, `title1`: -0.8, `headline`: -0.4).
- **Mandatory Tabular Figures**: Verify all chronometers, elapsed times, counters, and statistics use OpenType tabular figures (`.withTabularFigures()` / `FontFeature.tabularFigures()`).

### Step 4: Semantic Color & Theme Triad Audit
- Ensure no hardcoded raw hex colors (`Color(0xFF...)`) are used in presentation code.
- Verify color binding derives exclusively from `palette`:
  - `p.background`, `p.surface`, `p.surface2`, `p.surface3`, `p.border`, `p.accent`, `p.text`, `p.text2`, `p.text3`, `p.green`, `p.orange`, `p.red`.
- Verify readability across all 3 theme states: **Light**, **Dark**, and **AMOLED**.

### Step 5: Touch Target & Accessibility Audit
- Inspect interactive tap zones: every button, tile, and chip must occupy at least **48×48dp** (`NkTouchTarget.minInteractive`).
- Check that TalkBack semantic labels are present on all icon-only buttons.

### Step 6: Motion & Haptics Audit
- Verify standard Apple cubic curves (`NkCurves.appleEase` / `appleSpring`).
- Verify haptic feedback triggers on taps:
  - `HapticFeedback.selectionClick()` on tag/mode switches.
  - `HapticFeedback.mediumImpact()` on primary logging.

---

## 3. Safeguards
- Do not redesign or alter functioning layout hierarchies unless specifically addressing HIG non-compliance.
- Never regress working gestures (such as Predictive Back swipe or horizontal carousel panning).

---

## 4. Completion Criteria
- Complete HIG compliance checklist documented.
- All non-compliant tokens replaced with canonical `NkTokens`.
- Tests pass cleanly (`flutter test`).
