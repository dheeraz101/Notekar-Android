---
name: hig-review
description: Audit and review UI components, sheets, cards, and typography against NoteKar Apple HIG tokens and Android conventions.
---

# UI/UX & Apple HIG Review

Execute the UI/UX & Apple HIG review workflow for NoteKar:

1. Follow all steps in [.agents/workflows/03-ui-ux-apple-hig-review.md](file:///.agents/workflows/03-ui-ux-apple-hig-review.md).
2. Audit squircle geometry: `NkRadii.card` (16pt), `NkRadii.sheet` (28pt), `NkRadii.pill` (999pt).
3. Audit spacing: screen gutter 16pt, divider indent 54pt-56pt.
4. Audit typography: Inter font family, negative tracking, tabular figures for all numeric counters.
5. Audit colors: Bind semantic `Palette` tokens across Light, Dark, and AMOLED themes.
6. Audit touch targets: Minimum 48×48dp (`NkTouchTarget.minInteractive`).
7. Audit haptics and motion curves (`NkCurves.appleEase`, `selectionClick`).
