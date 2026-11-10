---
description: Mandatory standards for Android TalkBack accessibility, minimum touch targets, and contrast ratios
globs: lib/widgets/**/*.dart, lib/dialogs/**/*.dart, lib/screens/**/*.dart
---

# 08 - Accessibility (A11y) Standard

## 1. Touch Targets
- **48×48dp Minimum**: All interactive buttons, icon buttons, chips, and list tiles must meet or exceed Android's minimum touch target of **48×48dp** (`NkTouchTarget.minInteractive`).
- **Compact Exception**: Icon buttons in tight navigation toolbars may use **44×44dp** (`NkTouchTarget.minCompact`), with sufficient surrounding padding to prevent mis-taps.
- Never place interactive elements closer than `8dp` to each other.

## 2. TalkBack Semantics & Screen Readers
- Wrap icon-only buttons with `Tooltip` or `Semantics`:
  ```dart
  IconButton(
    icon: const Icon(Icons.add),
    tooltip: 'Log new moment',
    onPressed: _onLog,
  )
  ```
- Use descriptive semantic labels for chronometers and status indicators:
  ```dart
  Semantics(
    label: 'Session active in Deep Work, elapsed time 42 minutes',
    child: ClockFace(...),
  )
  ```
- Set `excludeFromSemantics: true` on decorative elements (e.g. background blur, gradient borders, dividers).

## 3. Visual Contrast & Readability
- All text must meet WCAG AA standards (minimum 4.5:1 contrast against its background container).
- Do not convey state through color alone; always pair color with text or an icon badge.
- Support Android system font scaling without text clipping. Avoid hardcoded `SizedBox(height: ...)` containers that cut off scaled text.
