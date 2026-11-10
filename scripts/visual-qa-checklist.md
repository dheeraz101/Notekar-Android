# NoteKar Visual Quality Assurance (QA) Checklist

Every AI agent modifying UI components, pages, sheets, cards, or dialogs must perform this visual verification before completing the task.

---

## 1. Capture Process
1. **Launch AVD / Device**:
   ```powershell
   emulator -avd Pixel_10a
   ```
2. **Deploy Build**:
   ```powershell
   flutter run -d Pixel_10a
   ```
3. **Capture Baseline & Modified States**:
   ```powershell
   .\scripts\capture-screen.ps1 -Tag "home_light"
   .\scripts\capture-screen.ps1 -Tag "home_dark"
   .\scripts\capture-screen.ps1 -Tag "home_amoled"
   ```

---

## 2. Visual Inspection Checklist

### A. Geometry & Shapes
- [ ] Inset grouped cards adhere to `NkRadii.card` (`16pt`) or `ContinuousSquircleBorder(radius: 24pt)`.
- [ ] Modal sheets and confirmation dialogs adhere to `NkRadii.sheet` / `NkRadii.dialog` (`28pt`).
- [ ] Status pills, segmented control capsules, and category tags adhere to `NkRadii.pill` (`999pt`).
- [ ] Dividers are inset with standard text alignment indent (`54pt` to `56pt`), not edge-to-edge.

### B. Typography & Tracking
- [ ] Font family is **Inter**.
- [ ] Proportional negative tracking applied on headers (`largeTitle`: -1.3, `title1`: -0.8, `headline`: -0.4).
- [ ] **Tabular figures** are active on all numeric data (chronometer, stopwatches, timestamps, counts) to eliminate digit vibration.
- [ ] Text scales cleanly when system font size is increased (no clipping or overlapping).

### C. Color & Contrast Across Themes
- [ ] **Light Theme**: Contrast ratio of text (`p.text`, `p.text2`) against `p.surface` and `p.background` is >= 4.5:1.
- [ ] **Dark Theme**: Clear distinction between `p.background` (canvas) and `p.surface` (card layer).
- [ ] **AMOLED Theme**: Pitch black `0x000000` canvas background with subtle elevated surface containers.
- [ ] Zero un-themed raw hex constants (`Color(0xFF...)`).

### D. Touch Targets & Ergonomics
- [ ] Every tap target measures at least **48×48dp** (`NkTouchTarget.minInteractive`).
- [ ] Compact toolbar actions measure at least **44×44dp** (`NkTouchTarget.minCompact`).
- [ ] Gaps between adjacent interactive buttons are at least **8dp**.

### E. Motion & Haptic Feedback
- [ ] Spring and ease transitions feel snappy (`150ms` to `250ms`).
- [ ] Tactile feedback triggers on tap: `HapticFeedback.selectionClick()` or `HapticFeedback.mediumImpact()`.
