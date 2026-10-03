# NoteKar Design System & Architectural Specification

> **Core Philosophy**: *"Simple for everyone. Powerful for people who need it."*  
> Grounded in Apple Human Interface Guidelines philosophy adapted authentically for Android platforms.

---

## 1. Design System Tokens

### 1.1 Typography Scale
NoteKar uses `Inter` as its canonical primary typography family with strict tabular figures for timestamps, stopwatch counters, and metrics.

| Token | Size | Weight | Tracking | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Display** | 34pt | FontWeight.w900 | -1.0 | Hero Clock Face, big milestone years |
| **Title Large** | 20pt | FontWeight.w800 | -0.3 | Page headlines, modal sheet headers |
| **Title Medium**| 16pt | FontWeight.w700 | -0.2 | Card section headers, list group titles |
| **Body Large**  | 16pt | FontWeight.w500 | -0.15 | Primary inputs, moment note content |
| **Body Medium** | 14pt | FontWeight.w400 | -0.1 | Standard description text, list subtitles |
| **Caption**     | 12.5pt | FontWeight.w400 | 0.0 | Explanatory footer notes, card helpers |
| **Label / Tag** | 11pt | FontWeight.w800 | +0.8 | Overline labels (`YOUR NAME`, `TAGS`), badges |
| **Numeric Data**| Var. | FontWeight.w700 | 0.0 | FontFeature.tabularFigures() for time & counters |

---

### 1.2 Spacing Scale
All margins, padding, and gaps derive strictly from `NkSpacing` / `AppTokens`:

```dart
static const double xxs  = 2.0;   // Micro adjustments, borders
static const double xs   = 4.0;   // Inner tag padding, tight element gaps
static const double sm   = 8.0;   // Icon-to-text spacing, compact vertical padding
static const double md   = 12.0;  // Standard gap between related fields
static const double lg   = 16.0;  // Canonical screen horizontal gutter & card margins
static const double xl   = 20.0;  // Card interior padding
static const double xxl  = 24.0;  // Section vertical gutters
static const double xxxl = 32.0;  // Empty state padding, hero offsets
```

---

### 1.3 Color System (`Palette`)
NoteKar enforces semantic palette mapping that dynamically adapts across Light, Dark, and AMOLED themes without hard-coded raw hex values in individual views.

* `p.background`: Canvas backdrop color.
* `p.surface`: Primary structural layer (app bars, modal sheet bodies).
* `p.surface2`: Inset grouped card containers (`NkCard`, `SettingsGroup`).
* `p.surface3`: Elevated controls, segmented pill backgrounds, active indicators.
* `p.border`: Hairline separator line with theme-aware alpha blending.
* `p.accent`: Primary brand action color (default electric blue, customizable).
* `p.text`: High-contrast primary copy.
* `p.text2`: Mid-contrast descriptive copy.
* `p.text3`: Low-contrast tertiary metadata, overlines, and disabled states.
* `p.green`: Positive state, goal completion, started sessions.
* `p.orange`: In-progress states, warnings, Memento Mori horizon.
* `p.red`: Destructive actions, pause state, urgent alerts.

---

### 1.4 Shapes & Corner Radii
Visual coherence requires strict geometric standardization. The canonical corner radius for cards and grouped containers is **16pt**.

```dart
static const Radius xs      = Radius.circular(6.0);   // Tiny badges, micro tags
static const Radius sm      = Radius.circular(8.0);   // Status chips, tag indicators
static const Radius md      = Radius.circular(12.0);  // Inner action buttons, inputs
static const Radius card    = Radius.circular(16.0);  // CANONICAL: NkCard, SettingsGroup, dialog cards
static const Radius sheet   = Radius.circular(28.0);  // Bottom sheet modal containers
static const Radius dialog  = Radius.circular(28.0);  // Confirmation dialogs
static const Radius pill    = Radius.circular(999.0); // Capsules, status pills, floating badges
```

---

## 2. Reusable Component Suite (`lib/widgets/design_system/`)

### 2.1 `NkCard`
The single source of truth for all grouped list sections and card containers.
* **Grouped List constructor**: `NkCard(p: p, title: 'SECTION', children: [ ... ])` automatically inserts hairline dividers aligned with content indent (`dividerIndent: 54.0`).
* **Container constructor**: `NkCard.container(p: p, padding: const EdgeInsets.all(18), child: ...)` standardizes custom layouts to the 16pt radius and theme-aware borders.

### 2.2 `NkListTile` & `NkSwitchTile`
Replaces ad-hoc list items and settings rows with Android-accessible items:
* Minimum 48dp touch target height.
* Squircle colored icon badge container with 8pt radius.
* Standard trailing chevrons, status text, or `Switch.adaptive`.

### 2.3 `NkButton`
Unified button component providing 4 variants:
* `NkButton.primary`: Bold accent-filled button for primary actions (e.g. Save Profile, Log Moment).
* `NkButton.secondary`: Calm surface2-filled button with hairline border for secondary actions.
* `NkButton.ghost`: Subtle borderless text button for dismiss or cancellation.
* `NkButton.destructive`: Prominent red-tinted button for irreversible actions (e.g. Empty Trash).
* Features: Built-in `isLoading` state, optional full-width expansion, and `PressableScale` tactile feedback.

### 2.4 `NkEmptyState`
Coherent empty-state view featuring:
* Calm circular icon illustration.
* Clear title and descriptive guidance on how to populate data.
* Optional primary action button (e.g. "Create Quick Local Backup", "Start Session").

---

## 3. UX Principles & Interaction Architecture

### 3.1 Progressive Disclosure
NoteKar prevents cognitive overload by organizing functionality into three distinct layers:
1. **Primary Layer (Home Screen)**: Focuses 100% on the core task: viewing current time, tapping to log an instantaneous moment, or starting/stopping a two-way session.
2. **Secondary Layer (History Ledger & Intelligence Hub)**: Accessible via smooth swipe-up or header taps. Presents chronological timelines, tag filters, circadian rhythms, and activity rings.
3. **Advanced Layer (Settings Domains)**: Configures biometric authentication, local backup snapshots, Memento Mori horizon, and notification intervals.

### 3.2 Navigation & Android Platform Respect
* **Zero Circular Navigation**: Subpages never cross-reference parent menus or duplicate screens in loops.
* **Native Android Transitions**: Standard Material 3 zoom transitions configured via `ZoomPageTransitionsBuilder()` for `TargetPlatform.android`.
* **Predictable Back Behavior**: Android hardware back button and predictive back gestures safely dismiss sheets and exit screens without state corruption.

### 3.3 TalkBack & Accessibility
* Primary logging touch zones provide dynamic spoken labels (`"Log a new moment"`, `"Start session"`, `"End session"`) and explicit action hints.
* Minimum touch targets of 48×48dp enforced across all interactive buttons and icon controls.

---

## 4. Product Vocabulary

To maintain product consistency across copy, documentation, and localization:

| Term | Definition |
| :--- | :--- |
| **Moment** | An instantaneous single-point timestamp log recorded with a single tap. |
| **Session** | A continuous two-way interval between Start and End timestamps. |
| **Timeline** | The unified chronological life ledger displaying moments and sessions. |
| **Activity Tag** | A customizable focus label (e.g., `#DeepWork`, `#Health`) categorized under a parent color. |
| **Executive Intelligence Hub** | The flagship analytics screen displaying activity rings, circadian rhythm, and 90-day consistency. |
| **Memento Mori Horizon** | The grounded conscious lifespan projection capped at 100 years. |
| **Sobriety Companion** | An offline habit recovery tracker with urge-surfing timers and milestone badges. |
| **Local Snapshot** | A zero-cloud, sandboxed JSON backup stored locally on device. |

---

## 5. Architectural Conventions

1. **100% Offline-First**: NoteKar has zero remote network telemetry, zero third-party tracking SDKs, and zero mandatory cloud dependencies.
2. **Preference Key Synchronization**: Canonical settings keys use the `'m-*'` format (`'m-theme'`, `'m-default-mode'`), synchronized bidirectionally with legacy fallback keys.
3. **Test Integrity Rule**: Any modification to widgets, controllers, or navigation routes must maintain 100% pass rates across the automated test suite (`flutter test`).
