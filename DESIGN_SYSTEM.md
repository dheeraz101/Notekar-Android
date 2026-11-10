# NoteKar Central Design System & Interaction Architecture

> **Design Philosophy**: *"Simple for everyone. Powerful for people who need it."*  
> Grounded in Apple Human Interface Guidelines spatial harmony, restrained minimalism, and tactile precision—authentically harmonized with Android native interaction conventions.

---

## 1. Core Principles: Apple HIG × Android Native

NoteKar rejects cluttered, generic material interfaces in favor of a bespoke fusion:
1. **Apple HIG Clarity & Restraint**:
   - Continuous superellipse squircle curvature (`ContinuousSquircleBorder`).
   - Subtle depth through inset grouped cards (`palette.surface2`) against calibrated backgrounds (`palette.bg`).
   - Negative optical letter-spacing on headlines matching Apple SF Pro typography.
   - OpenType tabular figures for all numeric counters, timers, and stopwatches to eliminate digit jitter.
   - Tactile intimacy through immediate, subtle haptic micro-feedback.
2. **Android Native Platform Authenticity**:
   - Material 3 Zoom page transitions (`ZoomPageTransitionsBuilder()`).
   - Predictive Back gesture integration with edge-drag non-contention (`PredictiveBackPeek`).
   - Dynamic edge-to-edge transparent system bars.
   - First-class home screen widgets (RemoteViews) synchronized with background state.
   - Flat monochrome status bar vector notification assets (`ic_stat_notekar`).
   - Android Quick Settings tiles (`FloatingBubbleTileService`, `QuickNoteTileService`).

---

## 2. Design Tokens Reference (`NkTokens` / `app_tokens.dart`)

All visual styling derives strictly from `NkTokens`. Never introduce arbitrary raw numbers or un-tokenized constants.

### 2.1 Spacing Scale (`NkSpacing`)
Margins, padding, and gaps derive strictly from the 8-point geometric scale:

| Token | Value | Semantic Usage |
| :--- | :--- | :--- |
| `NkSpacing.xxs` | `2.0pt` | Hairline micro-adjustments, border offsets |
| `NkSpacing.xs` | `4.0pt` | Inner tag padding, tight element gaps |
| `NkSpacing.sm` | `8.0pt` | Icon-to-text gaps, compact row vertical padding |
| `NkSpacing.md` | `12.0pt` | Standard gap between related input fields |
| `NkSpacing.lg` | `16.0pt` | Canonical screen gutter (`screenGutter`), card horizontal margin |
| `NkSpacing.xl` | `20.0pt` | Card interior padding, dialog body insets |
| `NkSpacing.xxl` | `24.0pt` | Vertical section gutters |
| `NkSpacing.xxxl`| `32.0pt` | Empty state padding, hero offsets |
| `NkSpacing.huge`| `48.0pt` | Top-of-screen hero clearances |

**Standard Insets**:
- Screen horizontal gutter: `16.0pt` (`NkSpacing.screenGutter`).
- Grouped section divider indent: `54.0pt` – `56.0pt` (`NkSpacing.dividerIndent`), aligning under the list tile text rather than the icon badge.
- Floating pill inner padding: `horizontal: 14pt, vertical: 8pt`.

---

### 2.2 Corner Radii & Geometry (`NkRadii`)
Curvature is calibrated to continuous superellipse squircles:

| Token | Radius Value | Canonical Usage |
| :--- | :--- | :--- |
| `NkRadii.xs` | `6.0pt` | Micro tags, notification count badges |
| `NkRadii.sm` | `8.0pt` | Status chips, icon badge squircle containers |
| `NkRadii.md` | `12.0pt` | Inner inputs, secondary action buttons |
| `NkRadii.button` | `14.0pt` | Primary call-to-action buttons |
| `NkRadii.card` | `16.0pt` | **CANONICAL**: Inset grouped cards (`NkCard`), settings groups |
| `NkRadii.cardGrouped` | `20.0pt` | Hero dashboard summary containers |
| `NkRadii.squircleCard` | `24.0pt` | Elevated prominent feature cards |
| `NkRadii.sheet` | `28.0pt` | Modal bottom sheet top curvature (`NkRadii.squircleSheet`) |
| `NkRadii.dialog` | `28.0pt` | Full-screen confirmation & alert dialogs |
| `NkRadii.pill` | `999.0pt` | Floating status capsules, segmented pill controls |

---

### 2.3 Typography Scale (`NkTypography`)
Primary typography family: **Inter** with calibrated optical tracking (letter spacing) and weight:

| Style Token | Size | Weight | Tracking | Usage |
| :--- | :--- | :--- | :--- | :--- |
| `largeTitle` | `34pt` | `FontWeight.w800` | `-1.3` | Hero clock display, primary screen titles |
| `title1` | `28pt` | `FontWeight.w700` | `-0.8` | Sheet headlines, modal titles |
| `title2` | `22pt` | `FontWeight.w700` | `-0.6` | Dashboard section headers |
| `title3` | `20pt` | `FontWeight.w600` | `-0.5` | Card titles, group labels |
| `headline` | `17pt` | `FontWeight.w600` | `-0.4` | Primary list item titles, button labels |
| `body` | `17pt` | `FontWeight.w400` | `-0.3` | Standard reading copy, moment notes |
| `callout` | `16pt` | `FontWeight.w400` | `-0.3` | Form inputs, dialog body text |
| `subheadline` | `15pt` | `FontWeight.w400` | `-0.2` | Secondary list item subtitles, timestamps |
| `footnote` | `13pt` | `FontWeight.w400` | `-0.1` | Metadata, badge labels |
| `caption` | `12pt` | `FontWeight.w500` | `0.0` | Explanatory footer text, card hints |
| `caption2` | `11pt` | `FontWeight.w500` | `0.0` | Overline uppercase category labels |

**OpenType Tabular Figures**:
All numeric strings (timestamps, stopwatches, live chronometers, percentages, streaks) must use `.withTabularFigures()`:
```dart
Text(
  formatTime(elapsed),
  style: NkTokens.typography.title1(p.text).withTabularFigures(),
)
```

---

### 2.4 Color System & Semantic Palette (`Palette`)
NoteKar enforces semantic palette mapping that dynamically adapts across themes without hardcoded raw hex values in individual views:

```dart
class Palette {
  final Color bg;        // Canvas backdrop (e.g. #000000 on AMOLED, #0F172A on Dark, #F8FAFC on Light)
  final Color surface;   // Primary structural layer (App bars, bottom sheets)
  final Color surface2;  // Inset grouped card containers (NkCard, settings rows)
  final Color surface3;  // Elevated interactive controls, pill segmented backgrounds
  final Color border;    // Hairline separator with theme-aware alpha blending
  final Color text;      // High-contrast primary copy
  final Color text2;     // Mid-contrast descriptive copy & subtitles
  final Color text3;     // Low-contrast tertiary metadata, overlines, disabled states
  final Color clock;     // Dedicated hero clock face color
  final Color accent;    // User-selected primary brand accent (Electric Blue, Emerald, Sunset, etc.)
  final Color green;     // Positive state, started sessions, streak milestones
  final Color orange;    // Warnings, in-progress timers, Memento Mori horizon
  final Color red;       // Destructive actions, pause state, urgent alerts
  final Color blue;      // Neutral informational state, sync badges
}
```

**Supported Theme Modes**:
- **Light Theme**: Crisp off-white canvas (`#F8FAFC`), pure white cards (`#FFFFFF`), subtle hairline borders (`0.5pt`).
- **Dark Theme**: Deep slate canvas (`#0B0F19`), elevated surface containers (`#151C2C`), refined contrast.
- **AMOLED Theme**: Pitch black backdrop (`#000000`) for absolute battery efficiency, elevated dark gray cards (`#121212`).
- **E-Ink Theme**: High-contrast monochrome palette for reflective e-paper displays.

---

### 2.5 Motion, Animation & Haptic Feedback

**Animation Curves (`NkCurves`)**:
- `appleEase`: `Curves.easeInOutCubic` (standard smooth layout shifts).
- `appleSpring`: `Cubic(0.25, 0.9, 0.35, 1.0)` (single-pass snappy entrance).
- `springSnappy`: `Curves.fastOutSlowIn` (quick micro-interactions).

**Durations (`NkDurations`)**:
- `micro`: `100ms` (color cross-fades).
- `fast`: `150ms` (button press scale recovery).
- `snappy`: `250ms` (dialog entrance, segmented pill slide).
- `smooth`: `350ms` (sheet expansion, timeline section reorganizing).

**Tactile Haptic Feedback**:
Every tap must be physically confirmed:
- `HapticFeedback.selectionClick()`: Segmented pill toggles, category tag clicks, switch flips.
- `HapticFeedback.mediumImpact()`: Primary timestamp logging, starting/stopping sessions.
- `HapticFeedback.heavyImpact()`: Permanent deletions, resetting data.

**Pressable Scale Feedback (`PressableScale`)**:
Interactive cards and buttons scale down to `0.97` on pointer press and spring back on release, providing authentic physical feedback.

---

## 3. Reusable Component Suite (`lib/widgets/design_system/`)

### 3.1 `NkCard`
The single authoritative container for grouped sections and standalone cards:
- **Grouped Section Constructor**:
  ```dart
  NkCard(
    p: p,
    title: 'SESSION CONFIGURATION',
    children: [
      NkListTile(p: p, title: 'Default Category', ...),
      NkSwitchTile(p: p, title: 'Auto-Pause', ...),
    ],
  )
  ```
  Automatically renders uppercase overline title (`caption2`) and hairline dividers with standard `54pt` indent between children.
- **Custom Container Constructor**:
  ```dart
  NkCard.container(
    p: p,
    padding: EdgeInsets.all(NkSpacing.xl),
    child: ...,
  )
  ```

### 3.2 `NkListTile` & `NkSwitchTile`
Standard iOS Inset Grouped list row tailored for Android:
- Guarantees minimum **48dp** touch target height.
- Squircle icon container with `8pt` radius and theme-aware surface tint.
- Trailing chevrons (`CupertinoIcons.chevron_right`), status text, or adaptive switches.

### 3.3 `NkButton`
Four standardized button variants:
1. `NkButton.primary`: Accent-colored high-emphasis button for main actions.
2. `NkButton.secondary`: Calm `surface2`-filled button with hairline border.
3. `NkButton.ghost`: Borderless text button for cancel/dismiss actions.
4. `NkButton.destructive`: Red-tinted button for irreversible operations.
All variants include built-in `isLoading` progress spinners, `PressableScale` tactile response, and full-width options.

### 3.4 `NkPillSegmentedControl`
iOS-style sliding segmented control with smooth physical sliding thumb and haptic clicks on value change.

### 3.5 `NkEmptyState`
Coherent empty-state view featuring calm iconography, title, descriptive copy, and optional call-to-action button.

---

## 4. Dialogs & Modal Surfaces

- **Bottom Sheets**: Must use `NkRadii.squircleSheet` (`28pt` top continuous squircle). Always include top drag handle capsule (`4pt` height, `36pt` width, `NkRadii.pill`).
- **Confirmation Dialogs**: Use `NkRadii.dialog` (`28pt`). Primary action on right (or bottom in stacked layouts), cancel on left.
- **Photo Lightbox**: Full-screen immersive black canvas with pinch-to-zoom, swipe-to-dismiss, and top translucent toolbar.

---

## 5. Navigation & Android Platform Conventions

1. **Zero Circular Navigation**: Screens must never navigate into parent views or create circular navigation stacks.
2. **Predictive Back Gestures**: Hardware back and edge-swipe gestures must smoothly pop sheets and screens without state corruption.
3. **Dynamic Broadcast Receivers (API 26–36)**:
   - Dynamic registration with `ContextCompat.RECEIVER_EXPORTED` on API 33+.
   - Never register implicit system intents statically in `AndroidManifest.xml`.
4. **Status Bar & Lockscreen Notifications**:
   - Flat monochrome vector asset (`ic_stat_notekar`).
   - Action titles <= 8 characters (`📝 Log`, `🏷️ Modes`, `▶ Start`).
   - Maximum 3 actions per notification.

---

## 6. Accessibility (A11y) Standards

1. **Minimum Touch Target**: Every interactive element must occupy at least **48×48dp** (`NkTouchTarget.minInteractive`).
2. **TalkBack Support**:
   - All icon-only buttons require an explicit `tooltip` or `Semantics(label: ...)`.
   - Dynamic counters must announce context (e.g. `"Timer active, elapsed 15 minutes"`).
3. **Contrast Ratios**: Minimum 4.5:1 text-to-background contrast ratio across all theme modes.
4. **Dynamic Font Scaling**: Layouts must use flexible flex/column containers to accommodate user-scaled system fonts without clipping text.
