# NoteKar Apple HIG & BitChord Refinements Master Index & Transformation Plan

> **Sovereign Product Design & Architectural Modernization Assessment**  
> **Target Application:** NoteKar (Flutter / Android)  
> **Inspiration Systems:** Apple Human Interface Guidelines (HIG) + BitChord Android Architecture  
> **Scope:** Full Visual System, Interaction Design, Physics, Navigation, Surfaces & Tokens  
> **Catalog Total:** 165 Distinct, Granular High-Value Refinements (APPLE-001 through APPLE-165)  
> **Status:** Phase 1 (Analysis), Phase 2 (Audit), Phase 3 (Direction), Phase 4 & 5 (Catalog), Phase 6 (Implementation), Phase 7 (Verification)

---

## 1. Executive Summary & Design Mission

NoteKar has progressed through two initial rounds of enhancement (Wave 1: 100 improvements, Wave 2: 505 micro-improvements). While functionally powerful and robust, a critical design paradox emerged:
The application was attempting to emulate an iOS interface directly inside an Android container, resulting in an experience that neither felt authentically iOS nor leveraged the strengths of modern Android.

The mission of this transformation is **not to clone iOS**.  
The mission is to build an **exceptionally polished Android application embodying Apple's design philosophy, visual restraint, interaction quality, and attention to detail, synthesized with BitChord's Android-native implementation techniques and NoteKar's own sovereign offline identity**.

$$\text{Apple Design Philosophy} + \text{BitChord Android Realization} + \text{NoteKar Sovereign Identity}$$

---

## 2. Phase 1: Deep Analysis of BitChord Reference Architecture

BitChord (`github.com/kushagrasinghx/BitChord`) is a premium music and chord companion for Android built with Kotlin and Jetpack Compose. A deep forensic analysis of BitChord's source code reveals why it feels remarkably refined:

### 2.1 Design Principles Distilled from BitChord
1. **Curvature Smoothing (Squircle vs. Circular Arc):**
   - BitChord rejects standard circular rounded corners (`RoundedCornerShape`). Standard circles exhibit an abrupt jump in curvature where the arc meets the straight run (the "hard shoulder").
   - BitChord implements `ContinuousCornerShape` with a smoothing factor of `0.607f` (Apple / Figma 60.7% corner smoothing), using cubic Bezier ramps that ease gradually into the straight edge.
2. **SF Pro Typography & Letter-Spacing Dynamics:**
   - SF Pro Display vs. SF Pro Text spacing physics: Text under 20pt is spaced looser (`+0.05` to `+0.4` letter-spacing) to guarantee legibility at small cuts. Display titles (>= 20pt) tighten their tracking (`-0.2` to `-0.5`).
3. **True Spring Physics over Artificial Bounce:**
   - BitChord explicitly avoids multi-pass bouncing springs (`dampingRatio = 0.5` is rejected because it overshoots 2-3 times, feeling like a toy).
   - BitChord tunes springs to `dampingRatio = 0.72f` to `0.78f` and `stiffness = 320f` to `700f`. This produces exactly **one soft pass beyond the mark and settles**—the tactile sensation of physical material rather than exaggerated springiness.
4. **Restraint in Glass & Translucency:**
   - BitChord does not place blur or glass everywhere.
   - Glass is reserved for floating chrome (the floating navigation bar and floating circular back/actions pills).
   - Hairline border width is locked to `0.5.dp` with `Color.White.copy(alpha = 0.10f)` on dark themes.
   - Under "Reduce dynamic blur" or unsupported hardware, surfaces gracefully fall back to clean solid fills (`MaterialTheme.colorScheme.surface`), preserving legibility and frame rates.
5. **Interactive Stretch on Controls (`IosSwitch`):**
   - Switches are not static toggles. The thumb physically elongates to `1.18x` stretch along the travel axis while pressed (`stiffness = 900f, damping = 0.7f`), communicating mechanical momentum.
   - Haptics occur strictly on value mutation (`LaunchedEffect(checked)`), not on initial touch.
6. **Lifted Pill Segmented Controls (`PillSegmentedControl`):**
   - Track uses Apple's tertiary fill (`Color(0xFF767680)` at `0.12` alpha light / `0.24` alpha dark).
   - Active segment is a lifted squircle pill (`Color.White` on light, `Color(0xFF636366)` on dark) that slides smoothly between options without layout rebuilds.
7. **Floating Navigation Bar Geometry:**
   - Screen gutter: `NAV_BAR_GUTTER = 19.dp` (wider than page margin).
   - Bottom lift: `NAV_BAR_LIFT = 6.dp` above navigation insets.
   - Tab icon size: `28.dp` glyph box. Tab label: `10.sp` with `0.5.sp` letter-spacing.
   - Pill inset: `4.dp` between outer rim and tab targets.

---

## 3. Phase 2: Forensic Audit of NoteKar & Architectural Inconsistencies

A comprehensive audit of NoteKar's current codebase (`lib/`) identified specific areas where the application either overdid iOS imitation or failed to achieve consistency:

1. **Triplicate Switch Implementations:**
   - `SettingsSwitchRow` implements a custom animated stack with hardcoded `|` and `O` lines.
   - `NkSwitchTile` embeds `Switch.adaptive`.
   - `HigSwitchRow` embeds `CupertinoSwitch`.
   - Result: Inconsistent touch response, mismatched drag kinetics, and jarring visual differences between dialogs.
2. **Pill Overuse on Action Buttons (`NkButton`):**
   - `NkButton` forced `borderRadius: NkTokens.radii.pill` (999.0) on all button variants, turning rectangular dialog actions and confirmation buttons into pill capsules.
3. **Corner Radius Disparity:**
   - `NkCard` used `16pt`.
   - `SettingsGroup` and `HigGroupedCard` used `28pt`.
   - `SegmentedSetting` used `16pt`.
   - Sheets used `24pt` or `28pt`.
4. **Exaggerated Letter-Spacing on Body Copy:**
   - Negative letter-spacing (`-0.1` to `-0.4`) was applied across small body styles (`11pt` to `15pt`), causing cramped, colliding glyphs on standard Android DPIs.
5. **Excessive Multi-Bounce on Toolbar Goal Switcher:**
   - `Toolbar` executed a 4-pass bouncing tween (`-8, +6, -3, 0`) over 700ms, creating visual distraction.
6. **Over-Grounded Glass in Settings:**
   - `SegmentedSetting` wrapped simple segmented rows in `Glass` containers with multi-stop gradients and heavy drop shadows, cluttering clean settings cards.
7. **Touch Target Deficits on Floating Sheet Chrome:**
   - Circular close/back buttons in sheet headers were sized at 32x32 without guaranteed 44x44 minimum touch targets.
8. **Inconsistent Dividers:**
   - Indents varied arbitrarily between 0, 54, and 56 across list tiles and grouped cards.

---

## 4. Phase 3: Unified Design Direction & Principles

### Design Principles
1. **Restraint over Decoration:** Every border, shadow, and tint must serve structural clarity.
2. **Native over Imitation:** NoteKar is an Android application. It respects Android back gestures, window insets, system themes, and accessibility semantics.
3. **Consistency over Individual Beauty:** A single unified design token language applies across every screen, sheet, card, and button.
4. **Functionality over Appearance:** High readability, WCAG AAA contrast where applicable, and zero layout shift.
5. **Subtlety over Exaggeration:** Single-pass damped spring motion (damping `0.72` - `0.78`) replacing multi-oscillation bounces.
6. **Content over Containers:** Spacing and typographic hierarchy define sections rather than nesting cards within cards.
7. **Purposeful Motion:** Motion communicates state changes, orientation, and spatial continuity.

---

## 5. Phase 4 & 5: Inventory of 165 High-Value Refinements (APPLE-001 to APPLE-165)

The complete catalog is structured into 10 domains:
- **A. Design System, Tokens, Surfaces & Curvature (APPLE-001 – APPLE-020)**
- **B. Typography Hierarchy, Tracking & Tabular Numbers (APPLE-021 – APPLE-035)**
- **C. Unified Toggle, Segmented Controls & Form Inputs (APPLE-036 – APPLE-052)**
- **D. Inset Grouped Cards, Lists & Separators (APPLE-053 – APPLE-070)**
- **E. Glass, Translucency & Restrained Layering (APPLE-071 – APPLE-085)**
- **F. Navigation, Floating Bottom Bar & Top Bars (APPLE-086 – APPLE-102)**
- **G. Modal Sheets, Dialogs & Insets (APPLE-103 – APPLE-118)**
- **H. Motion, Springs, Easing & Physics (APPLE-119 – APPLE-135)**
- **I. Haptics, Gestures & Micro-Interactions (APPLE-136 – APPLE-150)**
- **J. Dark Mode, Theming & Premium Finishing Details (APPLE-151 – APPLE-165)**

---

### Section A: Design System, Tokens, Surfaces & Curvature

#### APPLE-001: Continuous Squircle Curvature for Core Cards
- **Reference:** BitChord `ContinuousCornerShape.kt` (0.607 smoothing factor) & Apple HIG squircle geometry.
- **Our current implementation:** `NkCard` and `SettingsGroup` use standard circular arc `BorderRadius.circular(16/28)`.
- **Problem:** Circular corners produce an abrupt curvature jump ("hard shoulder") where arc meets straight edge.
- **Proposed refinement:** Introduce `NkSquircleBorder` and `NkTokens.radii.squircleCardBorder(radius: 20.0)` as default shape for grouped cards and dialog surfaces.
- **Expected result:** Visually harmonious, smooth corner transitions matching Apple surface treatment.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** Backward-compatible since `NkSquircleBorder` implements `ShapeBorder` / `RoundedRectangleBorder`.
- **Verification:** Inspect card edges; verify no corner clipping on child list items.

#### APPLE-002: Hairline Border Standardization (0.5dp True Hairline)
- **Reference:** BitChord `GLASS_EDGE_WIDTH = 0.5.dp`, `GLASS_EDGE_COLOR = Color.White.copy(alpha = 0.10f)`.
- **Our current implementation:** Border widths range from 0.4 to 0.8 with varying opacity (0.35 to 0.6).
- **Problem:** Visual noise and uneven edge weights between adjacent cards and sheets.
- **Proposed refinement:** Standardize `NkBorders.hairline = 0.5` as canonical border width across all cards, dialogs, and floating bars.
- **Expected result:** Clean, crisp structural edges that recede naturally.
- **Implementation location:** `lib/theme/app_tokens.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Verify border rendering across 1080p, 1440p displays.

#### APPLE-003: Button Shape De-Pillification
- **Reference:** Apple HIG & BitChord buttons: rectangular squircles (12-14pt radius), reserving pills strictly for tags/capsules.
- **Our current implementation:** `NkButton` hardcodes `borderRadius: NkTokens.radii.pill` (999.0) on all button variants.
- **Problem:** Turning every primary dialog action into a pill feels childish and loses structural gravity.
- **Proposed refinement:** Allow configurable `isPill` with default `false` using `NkTokens.radii.button` (14.0 continuous squircle) for dialog actions, keeping pill option for chips/floating actions.
- **Expected result:** Adult, refined button hierarchy with balanced touch targets.
- **Implementation location:** `lib/widgets/design_system/nk_button.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** Ensure existing button call sites render with proper padding.
- **Verification:** Check dialogs and action sheets for balanced button proportions.

#### APPLE-004: Standardized Screen & Bar Gutters
- **Reference:** BitChord `BAR_GUTTER = 16.dp`, `NAV_BAR_GUTTER = 19.dp`.
- **Our current implementation:** Margins vary from 12 to 24dp arbitrarily across screens.
- **Problem:** Horizontal alignment shifts when transitioning between Home, History, and Settings.
- **Proposed refinement:** Add `NkSpacing.screenGutter = 16.0` and `NkSpacing.navBarGutter = 19.0` to `NkTokens.spacing`.
- **Expected result:** Cohesive horizontal rhythm across the entire app.
- **Implementation location:** `lib/theme/app_tokens.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Check margin alignment between bottom toolbar and main screen cards.

#### APPLE-005: Modal Sheet Corner Radius Calibration
- **Reference:** Apple HIG sheet corner radius is 24-28pt squircle with top edge curve.
- **Our current implementation:** Sheets mix 24pt circular, 28pt circular, and 20pt glass radii.
- **Problem:** Floating sheets look inconsistently rounded depending on entry route.
- **Proposed refinement:** Standardize `NkTokens.radii.sheetVal = 24.0` with squircle vertical curve for all modal bottom sheets.
- **Expected result:** Unified, elegant sheet presentation.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Open History, Settings, and Checkpoint sheets to verify identical top radius.

#### APPLE-006: Inset Grouped Section Padding & Inset Dividers (56dp)
- **Reference:** Apple HIG & BitChord grouped lists: 56dp divider indent aligning with row text.
- **Our current implementation:** Dividers use 54dp in `HigGroupedCard`, 56dp in `SettingsGroup`, and 0dp in flat cards.
- **Problem:** Visual jitter when transitioning between different dialogs.
- **Proposed refinement:** Standardize `NkSpacing.dividerIndent = 56.0` universally.
- **Expected result:** Perfectly aligned separators sitting directly beneath text copy.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/widgets/design_system/nk_card.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect list separators in Settings and History.

#### APPLE-007: Subtle Ambient Shadow Calibration
- **Reference:** BitChord ambient shadow: soft alpha `0.06` light, `0.25` amoled, blur 16-24, offset `(0, 4)`.
- **Our current implementation:** Glass shadow in `Glass` had `blurRadius: 28` and spread `-3`, causing dark smudges on some OLED screens.
- **Problem:** Heavy shadows look muddy on dark backgrounds and conflict with minimalist aesthetics.
- **Proposed refinement:** Calibrate `NkTokens.elevation.cardShadow` to blur `16.0`, offset `(0, 4)`, alpha `0.04` light / `0.20` dark.
- **Expected result:** Subtle lift that separates surfaces without visible smudge.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/widgets/glass.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect on OLED black theme for clean floating contrast.

#### APPLE-008: Touch Target Safety Floor (44pt Compact / 48pt Primary)
- **Reference:** Apple HIG 44pt tap target standard; Android Material 48dp minimum.
- **Our current implementation:** Some header icons were 30-32dp without constraint wrappers.
- **Problem:** Missed taps on small circular buttons in header bars.
- **Proposed refinement:** Enforce `ConstrainedBox(constraints: BoxConstraints(minWidth: 44.0, minHeight: 44.0))` on all interactive icons.
- **Expected result:** 100% reliable tap recognition.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Verify tap targets via Flutter Widget Inspector bounds.

#### APPLE-009: Color Palette Luminous Hierarchy Refinement
- **Reference:** BitChord `DarkColors`: background `#000000`, surface `#0D0D0F`, surfaceVariant `#1C1C1E`.
- **Our current implementation:** `Palette.bg` is `#000000`, `surface` is `#1C1C1E`, `surface2` is `#2C2C2E`.
- **Problem:** Excellent base, but light theme `surface2` and `surface` are both `#FFFFFF`, collapsing layer hierarchy.
- **Proposed refinement:** In light theme, set `bg = #F2F2F7`, `surface = #F7F7F9`, `surface2 = #FFFFFF` for clear grouped separation.
- **Expected result:** Distinct tonal layering in both light and dark modes.
- **Implementation location:** `lib/models/palette.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Verify light mode cards visually detach from background.

#### APPLE-010: Surface 3 Tertiary Fill Calibration
- **Reference:** Apple HIG tertiary fill `#767680` with alpha `0.24` dark, `0.12` light.
- **Our current implementation:** `surface3` in dark theme is `#3A3A3C`, which is slightly too high contrast for subtle chip fills.
- **Problem:** Control fills draw more attention than the actual labels they contain.
- **Proposed refinement:** Calibrate `surface3` for chips/tracks to blend smoothly with surface2.
- **Expected result:** Restrained, content-first control fills.
- **Implementation location:** `lib/models/palette.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect search chips and segmented control backgrounds.

#### APPLE-011: Unified Icon Squircle Container Size (32x32 / 8dp Radius)
- **Reference:** BitChord & Apple HIG: settings row icons in 30-32pt squircles with 7-8pt radius.
- **Our current implementation:** `SettingsRow` used 36x36 with 10 radius; `NkListTile` used 32x32 with 8 radius; `HigRow` used 30x30 with 8 radius.
- **Problem:** Three different icon badge sizes across rows in the same app.
- **Proposed refinement:** Standardize all row icon containers to 32x32 with 8dp continuous squircle radius.
- **Expected result:** Perfectly uniform icon visual weight.
- **Implementation location:** `lib/widgets/settings_widgets.dart`, `lib/widgets/design_system/nk_list_tile.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Compare settings rows and history rows side-by-side.

#### APPLE-012: Drag Handle Visual Weight Calibration
- **Reference:** Apple modal sheet grabber: 36x5 capsule, `#8E8E93` at 0.35 alpha.
- **Our current implementation:** Sheet grabber is 36x5 but occasionally obscured by top header stack.
- **Problem:** Grabber handle can appear visually detached or collide with small titles.
- **Proposed refinement:** Position grabber in a dedicated 20pt vertical zone with 8pt top padding.
- **Expected result:** Calm, centered sheet grabber that guides dismiss gesture.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Verify sheet handle position on both docked and floating sheets.

#### APPLE-013: Destructive Action Color Balance
- **Reference:** Apple HIG system red `#FF3B30` with subtle background tint `0.12`.
- **Our current implementation:** Destructive buttons in some sheets used full opacity red or 0.15 alpha borders.
- **Problem:** Harsh visual alarm on routine deletion dialogs.
- **Proposed refinement:** Use `p.red` with `0.10` alpha background and clean hairline border for secondary destructive states.
- **Expected result:** Clear affordance without jarring aesthetic shock.
- **Implementation location:** `lib/widgets/design_system/nk_button.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Check Trash Bin and Delete Confirmation dialogs.

#### APPLE-014: High Contrast Border Enforcement Token
- **Reference:** Apple Accessibility: high contrast mode enables distinct borders around all surfaces.
- **Our current implementation:** High contrast boolean exists in palette but isn't consistently applied to card borders.
- **Problem:** Low visibility for visually impaired users on certain panel borders.
- **Proposed refinement:** When `highContrast == true`, guarantee `p.border` has minimum 0.8 alpha and 1.0 width.
- **Expected result:** Fully accessible high contrast card boundaries.
- **Implementation location:** `lib/models/palette.dart`, `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Toggle High Contrast in Settings and verify crisp border rendering.

#### APPLE-015: Empty State Vector & Typographic Alignment
- **Reference:** Apple HIG empty states: restrained icon in subtle container, headline, callout, optional primary button.
- **Our current implementation:** `NkEmptyState` has varying padding and occasionally outputs empty spacing widgets.
- **Problem:** Stutter in screen readers and awkward vertical centering.
- **Proposed refinement:** Standardize `NkEmptyState` with 44x44 icon container, headline 17pt, callout 14pt, conditional spacing.
- **Expected result:** Clean, purposeful empty views across Notes, Checkpoints, and Goals.
- **Implementation location:** `lib/widgets/design_system/nk_empty_state.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** View empty search, empty trash, and empty habits screens.

#### APPLE-016: Focus Ring / Active Outline Semantics
- **Reference:** Modern Android 14/15 keyboard navigation: subtle accent focus ring.
- **Our current implementation:** Focus outlines were missing on custom pressables.
- **Problem:** Physical keyboard navigation lacks visual focus indicators.
- **Proposed refinement:** Add focus highlight support to `PressableScale` and `NkButton`.
- **Expected result:** Smooth keyboard navigation on tablets, Chromebooks, and external keyboards.
- **Implementation location:** `lib/widgets/pressable_scale.dart`, `lib/widgets/design_system/nk_button.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Navigate with Tab key and arrow keys on physical keyboard.

#### APPLE-017: Floating Action Capsule Proportions
- **Reference:** BitChord `FloatingBottomBar.kt`: `PILL_INSET = 4.dp`, `NAV_BAR_LIFT = 6.dp`.
- **Our current implementation:** Floating capsules have varied internal padding (8 to 12dp).
- **Problem:** Excessive empty space around navigation icons inside the floating pill.
- **Proposed refinement:** Standardize floating capsule padding to 4dp inset around active selections.
- **Expected result:** Compact, premium floating navigation capsule.
- **Implementation location:** `lib/widgets/toolbar.dart`, `lib/widgets/home_minimal_toolbar_capsule.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect bottom toolbar proportions on device.

#### APPLE-018: Dialog Surface Proportion & Inset Scale
- **Reference:** Apple HIG dialog standard: max width 320pt on compact phones, 400pt on tablets, 20pt padding.
- **Our current implementation:** Some dialogs stretched across the screen or had 12pt padding.
- **Problem:** Text crowding edges of dialog cards.
- **Proposed refinement:** Constrain dialog widths to 320-380pt with 20pt horizontal and 20pt vertical padding.
- **Expected result:** Balanced, elegant alert dialog presentation.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Check confirm reset and vault password dialogs.

#### APPLE-019: Pill Tag & Chip Padding Calibration
- **Reference:** BitChord `LABEL_PADDING = 18.dp`, `LABEL_VERTICAL_PADDING = 9.dp`.
- **Our current implementation:** Category and filter chips had tight 8x4 padding, making labels look cramped.
- **Problem:** Chips felt crowded rather than distinct tappable tags.
- **Proposed refinement:** Refine chip padding to `horizontal: 14.0, vertical: 7.0` with `13sp` text.
- **Expected result:** Breathable, legible tags.
- **Implementation location:** `lib/theme/app_tokens.dart`, `lib/widgets/home_category_pills.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Verify home screen category pills.

#### APPLE-020: Consistent Edge-to-Edge Scrim Token
- **Reference:** Android 15 edge-to-edge system navigation: transparent navigation bars without dark gray wash.
- **Our current implementation:** Enforced in `main.dart`, but some modal sheet routes reintroduced default black scrims.
- **Problem:** Harsh darkening behind sheets instead of Apple's calm ambient dimming.
- **Proposed refinement:** Use `Colors.black.withValues(alpha: 0.38)` as standard sheet modal barrier color.
- **Expected result:** Soft, atmospheric background dimming behind sheets.
- **Implementation location:** `lib/main.dart`, `lib/dialogs/app_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Open any bottom sheet and verify soft background scrim.

---

### Section B: Typography Hierarchy, Tracking & Tabular Numbers

#### APPLE-021: SF Pro Text / Display Tracking Calibration
- **Reference:** BitChord `Theme.kt`: Sizes < 20pt have positive tracking (`+0.05` to `+0.4`); sizes >= 20pt have negative tracking (`-0.2` to `-0.5`).
- **Our current implementation:** `main.dart` textTheme sets negative letter-spacing (`-0.1` to `-0.4`) across body copy (11-16pt).
- **Problem:** Text glyphs cram together on standard mobile DPIs, harming readability.
- **Proposed refinement:** Calibrate `textTheme`: `bodyLarge` (16pt, +0.1), `bodyMedium` (14pt, +0.15), `labelMedium` (12pt, +0.2), `labelSmall` (11pt, +0.25); headlines maintain crisp negative tracking (-0.2 to -0.4).
- **Expected result:** Instant elevation in readability and typographical elegance.
- **Implementation location:** `lib/main.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None (maintains existing font family and sizes).
- **Verification:** Inspect reading comfort across timeline notes and settings descriptions.

#### APPLE-022: Tabular Numeric Tracking for Live Session Timers
- **Reference:** BitChord `PlaybackPosition.kt` & Apple HIG: OpenType `tnum` (tabular figures) for numbers that change dynamically.
- **Our current implementation:** Timer numbers use standard proportional figures in several places, causing the clock label width to wiggle as numbers increment (e.g. `1` vs `8`).
- **Problem:** Jittery text layout every second during focus sessions.
- **Proposed refinement:** Apply `.withTabularFigures()` (`FontFeature.tabularFigures()`) to all timer and clock displays.
- **Expected result:** Rock-solid, non-jittering timer readouts.
- **Implementation location:** `lib/widgets/clock_face.dart`, `lib/widgets/dynamic_header_capsule.dart`, `lib/widgets/toolbar.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Start a session timer; verify no horizontal shift when switching between 00:01 and 00:11.

#### APPLE-023: Large Title Header Proportions & Weight
- **Reference:** Apple HIG large title: 34pt, bold/extrabold, letterSpacing `-0.5`.
- **Our current implementation:** In `NkTypography`, `largeTitle` has `letterSpacing: -1.3`, which causes glyph collisions on certain Android systems.
- **Problem:** Overly compressed headlines looking squashed.
- **Proposed refinement:** Refine `largeTitle` in `ThemeData` to `-0.5` letter-spacing, w700/w800 weight.
- **Expected result:** Majestic, balanced top page titles.
- **Implementation location:** `lib/main.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect History and Settings root headers.

#### APPLE-024: Secondary Label Contrast Compliance (WCAG AA/AAA)
- **Reference:** Apple HIG secondary label `#8E8E93` on dark `#000000` gives 5.4:1 contrast (WCAG AA).
- **Our current implementation:** In light mode, `text3` was `#6C6C70`, which could drop below 4.5:1 on low-brightness screens.
- **Problem:** Subtle captions were hard to read in direct sunlight.
- **Proposed refinement:** Calibrate light mode `text3` to `#5A5A5E` (5.2:1 contrast) and dark mode `text3` to `#8E8E93`.
- **Expected result:** Crisp readability of subtitles and metadata in all lighting conditions.
- **Implementation location:** `lib/models/palette.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Run accessibility contrast checker on light mode captions.

#### APPLE-025: Section Header All-Caps Tracking
- **Reference:** Apple HIG & BitChord: small uppercase section headers (`12-13pt`) require wider letter-spacing (`0.6` to `0.8`).
- **Our current implementation:** Some section headers had `0.2` letter-spacing, making small capital letters look clustered.
- **Problem:** Section titles lacked breathing room.
- **Proposed refinement:** Standardize section headers to `12.0pt`, `FontWeight.w700`, `letterSpacing: 0.6`.
- **Expected result:** Classical, refined section titles.
- **Implementation location:** `lib/widgets/design_system/nk_card.dart`, `lib/widgets/settings_widgets.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect section titles in Settings and Checkpoints.

#### APPLE-026: Timeline Note Preview Line Clamping & Ellipsis
- **Reference:** Apple Notes & BitChord: timeline text clamped cleanly at 3-4 lines with trailing ellipsis.
- **Our current implementation:** Some long notes expanded indefinitely, monopolizing the timeline viewport.
- **Problem:** Long notes pushed subsequent timeline entries dozens of screens downward.
- **Proposed refinement:** Default note preview to 4 lines with a clean "Show more" toggle.
- **Expected result:** Compact, scannable timeline feed.
- **Implementation location:** `lib/widgets/timeline_single_tile.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Create a 500-word note; verify it clamps neatly to 4 lines with expansion affordance.

#### APPLE-027: Markdown Code Snippet Monospace Typography
- **Reference:** Apple HIG developer typography: SF Mono / JetBrains Mono / monospace with background pill.
- **Our current implementation:** Markdown code blocks used default system font without proper background contrast.
- **Problem:** Code snippets looked like normal text with slight indent.
- **Proposed refinement:** Style inline code with monospace font, 13pt, 0.15 alpha background, and 4pt squircle radius.
- **Expected result:** Clear, beautiful code formatting inside notes.
- **Implementation location:** `lib/widgets/markdown_text.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Write `code` in a note; verify crisp monospace badge.

#### APPLE-028: Metric Counter Tabular Numerics in Momentum Card
- **Reference:** BitChord statistics & Apple Activity rings: tabular metrics.
- **Our current implementation:** Momentum streak and time numbers used standard proportional figures.
- **Problem:** Numbers jitter when animating up.
- **Proposed refinement:** Wrap metric counters in `NkTextStyleTabular`.
- **Expected result:** Rock-steady counter increments.
- **Implementation location:** `lib/widgets/home_momentum_card.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Verify momentum numbers during daily updates.

#### APPLE-029: Voice Note Timestamp Formatting
- **Reference:** Apple Voice Memos: `0:00 / 1:23` format with tabular numbers.
- **Our current implementation:** Timestamps in audio pill used proportional text.
- **Problem:** Waveform scrubber timestamp jumped sideways while playing.
- **Proposed refinement:** Format voice note durations with tabular numbers and fixed width bounds.
- **Expected result:** Smooth, professional voice playback timer.
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Play an audio note; verify timer text is stable.

#### APPLE-030: Tab Bar Label Size & Spacing
- **Reference:** BitChord `FloatingBottomBar.kt`: label font size `10.sp`, letter-spacing `0.5.sp`.
- **Our current implementation:** Bottom toolbar labels used 11-12sp with 0.0 letter-spacing.
- **Problem:** Labels looked slightly too heavy under navigation glyphs.
- **Proposed refinement:** Set tab bar labels to 10.5pt, w600, letter-spacing `0.4`.
- **Expected result:** Proportional, elegant navigation labels.
- **Implementation location:** `lib/widgets/toolbar.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Check bottom toolbar labels.

#### APPLE-031: Checkpoints Quick Bar Metric Alignment
- **Reference:** Apple Fitness habit trackers: consistent horizontal baselines for completion counts.
- **Our current implementation:** Streak icons and numbers had slight 1px vertical misalignment.
- **Problem:** Visual jitter in quick-bar streak indicators.
- **Proposed refinement:** Align habit streak number and icon on shared center baseline.
- **Expected result:** Perfectly aligned habit cards.
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Inspect streak numbers in quick-bar.

#### APPLE-032: Digital Wellbeing Screen Time Typography
- **Reference:** Apple Screen Time: prominent hour number with small 'h' and 'm' unit labels.
- **Our current implementation:** Plain string `3h 12m` rendered in uniform weight.
- **Problem:** Looks unstyled compared to native wellbeing dashboards.
- **Proposed refinement:** Split hours and minutes with distinct numeric weights and muted unit letters.
- **Expected result:** Glanceable, premium executive intelligence display.
- **Implementation location:** `lib/widgets/digital_wellbeing_card.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect Digital Wellbeing card on home screen.

#### APPLE-033: Search Field Placeholder Tracking
- **Reference:** BitChord `SearchField.kt`: placeholder text spaced naturally with muted secondary label color.
- **Our current implementation:** Placeholder text in search dialogs had varied opacities.
- **Problem:** Placeholder text looked either too bright or faded out.
- **Proposed refinement:** Set search placeholder to `p.text3` with `15pt`, regular weight, `+0.1` tracking.
- **Expected result:** Clean, inviting search inputs.
- **Implementation location:** `lib/dialogs/search_dialogs.dart`, `lib/dialogs/settings/settings_dialog_search.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Open Search dialog and inspect placeholder field.

#### APPLE-034: Dialog Action Button Typography
- **Reference:** Apple alert dialogs: Bold `17pt` for default action, regular `17pt` for cancel.
- **Our current implementation:** Dialog buttons had uniform medium weight.
- **Problem:** Lacked clear primary vs secondary visual guidance.
- **Proposed refinement:** Set primary action to `16.5pt, FontWeight.w700`, cancel action to `16.5pt, FontWeight.w500`.
- **Expected result:** Immediately clear primary action in confirmation dialogs.
- **Implementation location:** `lib/dialogs/backup_dialogs.dart`, `lib/dialogs/reset_sheets.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Trigger a delete/reset dialog; verify visual hierarchy.

#### APPLE-035: Milestone Celebration Title Typography
- **Reference:** Apple Fitness award badges: punchy title with elegant subtitle.
- **Our current implementation:** Milestone celebration had generic title style.
- **Problem:** Did not feel ceremonial or rewarding.
- **Proposed refinement:** Apply `title1` (28pt, w800, -0.6 tracking) with subtle gold/accent shimmer.
- **Expected result:** Rewarding, premium milestone celebration.
- **Implementation location:** `lib/widgets/milestone_celebration_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Complete a milestone and inspect celebration dialog.

---

### Section C: Unified Toggle, Segmented Controls & Form Inputs

#### APPLE-036: Unified Apple-Inspired Switch Component (`NkIosSwitch`)
- **Reference:** BitChord `IosSwitch.kt`: track 64x28 or 51x31 capsule, white thumb with mechanical stretch (1.18x) while pressed, Apple green on-track, haptic on value flip.
- **Our current implementation:** Three disparate switches (`SettingsSwitchRow`, `NkSwitchTile`, `HigSwitchRow`).
- **Problem:** Fragmented behavior, awkward touch feedback, duplicated screen reader announcements.
- **Proposed refinement:** Build a unified `NkIosSwitch` widget matching BitChord's spring physics, thumb stretch, and haptic timing; adopt it in `NkSwitchTile`, `SettingsSwitchRow`, and `HigSwitchRow`.
- **Expected result:** Flawless, tactile switch experience across all settings and forms.
- **Implementation location:** `lib/widgets/design_system/nk_ios_switch.dart`, `lib/widgets/design_system/nk_list_tile.dart`, `lib/widgets/settings_widgets.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Medium.
- **Priority:** Critical.
- **Risk:** Low (standard `value` / `onChanged` API).
- **Verification:** Toggle switches across Display, Privacy, Reminders; verify smooth stretch and haptic buzz.

#### APPLE-037: Reusable Sliding Pill Segmented Control (`NkPillSegmentedControl`)
- **Reference:** BitChord `PillSegmentedControl.kt`: squircle track in tertiary fill, lifted white/charcoal pill sliding smoothly with spring motion (`damping = 0.8`).
- **Our current implementation:** `SegmentedSetting` wraps in heavy Glass; `GoalsSheet` uses `CupertinoSegmentedControl`; `LifeAuditPage` uses ad-hoc pills.
- **Problem:** Visual inconsistency and heavy rendering cost from unnecessary backdrop blurs.
- **Proposed refinement:** Build `NkPillSegmentedControl` matching BitChord's exact metrics: track padding 4dp, label padding 14dp, spring damping 0.8, sliding pill.
- **Expected result:** Clean, lightweight, physically grounded segment switching.
- **Implementation location:** `lib/widgets/design_system/nk_pill_segmented_control.dart`, `lib/widgets/settings_widgets.dart`, `lib/dialogs/goals_sheet.dart`.
- **Complexity:** Medium.
- **Priority:** Critical.
- **Risk:** Low.
- **Verification:** Switch segments in Settings, Goals, and Life Audit.

#### APPLE-038: Switch Semantic Accessibility Double-Speaking Fix
- **Reference:** Android TalkBack guidelines: interactive row should announce switch state once.
- **Our current implementation:** Outer `Semantics(toggled: ...)` + inner interactive switch caused double announcement.
- **Problem:** TalkBack users hear "Checked, checked" on every tap.
- **Proposed refinement:** Wrap inner switch in `ExcludeSemantics` while preserving outer row semantics.
- **Expected result:** Single, clear TalkBack state announcement.
- **Implementation location:** `lib/widgets/design_system/nk_list_tile.dart`, `lib/widgets/settings_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Test with TalkBack / Accessibility Scanner.

#### APPLE-039: Interactive Stepper Control ([-] [+] with Spring Response)
- **Reference:** Apple HIG Stepper control: continuous rounded pill containing `[-]` and `[+]` divided by hairline.
- **Our current implementation:** Some steppers used separate disconnected buttons.
- **Problem:** Disjointed controls occupying unnecessary horizontal space.
- **Proposed refinement:** Build `NkStepper` with unified squircle container, tactile touch-down scale, and continuous increment on hold.
- **Expected result:** Compact, delightful numeric adjustment for timer intervals and goal targets.
- **Implementation location:** `lib/widgets/design_system/nk_stepper.dart`, `lib/dialogs/personalization_setup_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Adjust focus session duration and target milestones.

#### APPLE-040: Clean Text Input Field Styling (Apple Inset Grouped Text Box)
- **Reference:** Apple HIG forms: input fields set on `surface3` / `surfaceVariant` squircle container, 44pt height, hairline active accent border.
- **Our current implementation:** Some input fields used Material default underlined inputs.
- **Problem:** Clashing design languages between forms and surrounding cards.
- **Proposed refinement:** Unify text fields inside squircle containers with clean 12pt horizontal padding and subtle active glow.
- **Expected result:** Natural, elegant text entry in Note composer and Goal setup.
- **Implementation location:** `lib/dialogs/note_dialog.dart`, `lib/dialogs/goals_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect note title and content text fields.

#### APPLE-041: Clear Button ('x') Touch Target & Positioning
- **Reference:** Apple HIG text fields: circular gray `x` clear button with 44x44 touch target.
- **Our current implementation:** Clear buttons were occasionally tight 20x20 icons difficult to tap accurately.
- **Problem:** Missed taps when trying to clear search query.
- **Proposed refinement:** Ensure clear icon has 44x44 minimum hit test area.
- **Expected result:** Effortless one-tap query clearing.
- **Implementation location:** `lib/dialogs/search_dialogs.dart`, `lib/dialogs/settings/settings_dialog_search.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Type in search bar and tap clear button.

#### APPLE-042: Slider Track & Thumb Refinement
- **Reference:** Apple HIG sliders: thin 4pt track, white circular thumb with subtle drop shadow.
- **Our current implementation:** Material 3 slider with oversized pill thumb in some settings.
- **Problem:** Overly heavy slider dominates settings rows.
- **Proposed refinement:** Custom `SliderThemeData` with 4pt track height, 24pt circular thumb, and crisp hairline ring.
- **Expected result:** Sleek, precise volume and delay sliders.
- **Implementation location:** `lib/dialogs/settings/advanced_settings_page.dart`, `lib/widgets/settings_widgets.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Adjust tap delay slider in Settings.

#### APPLE-043: Date & Time Picker Sheet Elevation
- **Reference:** Apple HIG date wheel / inline calendar: smooth continuous scrolling with soft haptic tick.
- **Our current implementation:** CupertinoDatePicker wrapped in basic card.
- **Problem:** Visual contrast of date picker wheels clashed with dark OLED themes.
- **Proposed refinement:** Wrap date picker in `NkCard` with unified `surface2` background and themed picker text.
- **Expected result:** Seamless date selection experience.
- **Implementation location:** `lib/dialogs/app_date_picker_sheet.dart`, `lib/dialogs/calendar_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Pick a milestone target date in Goals sheet.

#### APPLE-044: Tag Multi-Select Chip Visual Balance
- **Reference:** BitChord filter chips: subtle outline, filled accent on active, smooth scale feedback.
- **Our current implementation:** Some tags had heavy solid fills that obscured label text.
- **Problem:** Active tags looked visually cluttered.
- **Proposed refinement:** Active tag uses `p.accent.withValues(alpha: 0.16)` with crisp text and hairline border.
- **Expected result:** Lightweight, scannable tag cloud.
- **Implementation location:** `lib/dialogs/settings/activity_tags_settings_page.dart`, `lib/widgets/smart_search_chips_bar.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Toggle tags in search filter sheet.

#### APPLE-045: Checkbox Affordance Polish
- **Reference:** Apple Reminders: circular checklist radio that fills with accent checkmark on tap.
- **Our current implementation:** Square Material checkboxes in checkpoint habit checklists.
- **Problem:** Square checkboxes feel out of place against rounded squircle cards.
- **Proposed refinement:** Support circular checklist affordances (`NkChecklistButton`) with spring fill animation.
- **Expected result:** Satisfying, tactile habit checking.
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart`, `lib/dialogs/goals_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Check off a daily checkpoint habit.

#### APPLE-046: Color Palette Selector Swatch Squircle Styling
- **Reference:** Apple Wallpaper / Accent pickers: continuous squircles with active selection ring.
- **Our current implementation:** Color swatches were plain circles with checkmark.
- **Problem:** Disconnected from the rest of the squircle visual language.
- **Proposed refinement:** Render theme swatches as 36x36 continuous squircles with animated white outer ring.
- **Expected result:** Gorgeous accent color selection grid.
- **Implementation location:** `lib/dialogs/settings/display_settings_page.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Change accent color in Display settings.

#### APPLE-047: Form Field Error State Restraint
- **Reference:** Apple HIG forms: subtle red footnote text below field, no jarring shake or thick red box.
- **Our current implementation:** Some forms displayed heavy error banners.
- **Problem:** Visually aggressive error presentation.
- **Proposed refinement:** Render inline error as 12pt footnote in `p.red` with smooth fade-in.
- **Expected result:** Polite, constructive validation feedback.
- **Implementation location:** `lib/dialogs/vault_password_dialog.dart`, `lib/dialogs/note_dialog.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Enter invalid PIN in Vault dialog.

#### APPLE-048: Dropdown Menu / Context Popover Styling
- **Reference:** BitChord `IosMenu.kt`: floating charcoal/frost panel with hairline rim, rounded pressed rows.
- **Our current implementation:** Standard Material PopupMenu with square edges and heavy shadow.
- **Problem:** Drastic visual mismatch when popup opens.
- **Proposed refinement:** Style popup menus with `NkTokens.radii.squircleCardBorder(radius: 14)`, `p.surface2`, and hairline outline.
- **Expected result:** Beautiful, floating context menus.
- **Implementation location:** `lib/widgets/common_elements.dart`, `lib/widgets/apple_hig_action_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Open 3-dots menu on a timeline note.

#### APPLE-049: Keyboard Avoidance & Viewport Inset Handling
- **Reference:** Apple HIG iOS keyboard management: content smoothly shifts up without viewport overflow errors.
- **Our current implementation:** Occasional bottom overflow by 12px when keyboard opened on small screens.
- **Problem:** Yellow-and-black striped overflow error during rapid typing.
- **Proposed refinement:** Ensure all form sheets wrap content in `SingleChildScrollView` with `viewInsets.bottom` padding.
- **Expected result:** Zero keyboard layout overflows.
- **Implementation location:** `lib/dialogs/note_dialog.dart`, `lib/dialogs/manual_entry_dialog.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Open note editor with software keyboard on compact screen.

#### APPLE-050: PIN Setup Dot Animation Polish
- **Reference:** Apple iOS Passcode lock: smooth dot fill with gentle pulse on entry.
- **Our current implementation:** Static text bullets in PIN setup.
- **Problem:** Lacked tactile feedback during vault security setup.
- **Proposed refinement:** Animated 12pt circular dots that scale to `1.2x` briefly on digit press.
- **Expected result:** Delightful, bank-grade passcode entry.
- **Implementation location:** `lib/widgets/home_pin_setup_overlay.dart`, `lib/dialogs/vault_password_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Enter vault PIN digits and observe dot animations.

#### APPLE-051: Quick Action Icon Sizing in Sheets
- **Reference:** BitChord `FrostedTopBar.kt`: 44pt action pill with icons spaced 10pt apart.
- **Our current implementation:** Quick actions had varying icon sizes (16, 20, 24).
- **Problem:** Ragged horizontal rhythm in action bars.
- **Proposed refinement:** Standardize quick action icons to 18pt in 44pt touch slots.
- **Expected result:** Harmonious action rows.
- **Implementation location:** `lib/dialogs/app_sheet.dart`, `lib/widgets/checkpoints_quick_bar.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect action buttons in History sheet.

#### APPLE-052: Search Filter Clear State Indicator
- **Reference:** Apple Mail search filters: active badge counter with quick reset tap.
- **Our current implementation:** Filter badge was a plain number without one-tap clear affordance.
- **Problem:** Users had to open sheet to clear active filters.
- **Proposed refinement:** Add quick clear cross icon to active filter chip.
- **Expected result:** Immediate filter dismissal.
- **Implementation location:** `lib/dialogs/timeline_filter_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Filter timeline by category and tap filter clear icon.

---

### Section D: Inset Grouped Cards, Lists & Separators

#### APPLE-053: Inset Grouped Card Radius Unification (20pt Squircle)
- **Reference:** Apple HIG & BitChord: standard grouped cards use 16-20pt continuous squircle.
- **Our current implementation:** `NkCard` used 16, `SettingsGroup` used 28, `HigGroupedCard` used 28.
- **Problem:** 28pt is too large for dense lists, 16pt circular feels too boxy.
- **Proposed refinement:** Standardize grouped card radius to 20.0pt continuous squircle across all cards.
- **Expected result:** Perfect balance of softness and structural density.
- **Implementation location:** `lib/widgets/design_system/nk_card.dart`, `lib/widgets/settings_widgets.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Compare card corners across Settings, History, and Checkpoints.

#### APPLE-054: Content-First Visual Grouping (Eliminating Nested Cards)
- **Reference:** Apple HIG Principle: Content over Containers. Do not wrap cards inside cards.
- **Our current implementation:** Certain screens had `Glass` wrapping `NkCard` wrapping `Container`.
- **Problem:** Triple border lines and visual clutter.
- **Proposed refinement:** Strip nested inner card wrappers; use typographic hierarchy and subtle background separation.
- **Expected result:** Clean, calm content presentation.
- **Implementation location:** `lib/widgets/settings_widgets.dart`, `lib/dialogs/settings/display_settings_page.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect Display settings page for clean single-tier grouping.

#### APPLE-055: Chevron Alignment & Micro-Icon Sizing (15pt Cupertino Chevron)
- **Reference:** Apple HIG: trailing disclosure chevron is 15pt, subtle opacity `0.45`.
- **Our current implementation:** Some rows used Material `chevron_right_rounded` at 18pt, others used Cupertino at 14pt.
- **Problem:** Inconsistent chevron weight across rows.
- **Proposed refinement:** Standardize trailing chevron to 15.0pt with `p.text3.withValues(alpha: 0.5)`.
- **Expected result:** Whisper-thin, consistent disclosure chevrons.
- **Implementation location:** `lib/widgets/design_system/nk_list_tile.dart`, `lib/widgets/settings_widgets.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll through Settings root menu.

#### APPLE-056: Row Press Scale Physics (`PressableScale` 0.985x)
- **Reference:** BitChord tactile pressed state: subtle scale (0.985x) and immediate touch-up release.
- **Our current implementation:** Some rows had 0.96 scale (too aggressive), others used Material ripple (`InkWell`).
- **Problem:** Inconsistent row feedback across lists.
- **Proposed refinement:** Standardize list row tap feedback to `0.985x` scale with 120ms easeOutCubic curve.
- **Expected result:** Gentle, premium tactile confirmation of row taps.
- **Implementation location:** `lib/widgets/pressable_scale.dart`, `lib/widgets/design_system/nk_list_tile.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap rows in Settings and History.

#### APPLE-057: First & Last Item Corner Radius Isolation
- **Reference:** Apple HIG Inset Grouped Table: first row clips to top corners, last row clips to bottom corners.
- **Our current implementation:** Enclosing card handles clipping via `Clip.antiAlias`.
- **Problem:** Works when card has `antiAlias`, but individual row highlights could leak outside corners during drag.
- **Proposed refinement:** Ensure parent container maintains strict anti-alias squircle clipping with zero pixel bleed.
- **Expected result:** Pristine corner clipping during row presses.
- **Implementation location:** `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Press first and last rows in any grouped list.

#### APPLE-058: Row Subtitle Vertical Spacing & Line Height
- **Reference:** Apple HIG: subtitle sits 2-3pt below title with 1.25-1.35 line height.
- **Our current implementation:** Subtitle spacing varied between 2, 4, and 6pt.
- **Problem:** Uneven row heights across different settings pages.
- **Proposed refinement:** Lock subtitle spacing to `SizedBox(height: 2.5)` with `fontSize: 12.5`, `height: 1.3`.
- **Expected result:** Rhythmically consistent row heights.
- **Implementation location:** `lib/widgets/design_system/nk_list_tile.dart`, `lib/widgets/settings_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect multi-line subtitles in Security and Backup settings.

#### APPLE-059: Status Pill vs Text Distinction in List Rows
- **Reference:** Apple HIG: right-aligned status is either plain secondary text (`14pt`) or a subtle capsule badge for active states.
- **Our current implementation:** Status was sometimes plain text and sometimes brightly colored badges.
- **Problem:** Visual noise when multiple rows had different status badge styles.
- **Proposed refinement:** Muted secondary text for standard values; reserved colored capsule for critical alerts (e.g. "Backup Overdue").
- **Expected result:** Visually calm list with alerts that genuinely pop.
- **Implementation location:** `lib/widgets/design_system/nk_list_tile.dart`, `lib/widgets/settings_widgets.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect status indicators in Settings.

#### APPLE-060: Timeline Consolidated Card Visual Restraint
- **Reference:** Apple Health chronological feeds: clean white/dark tile with subtle left accent line.
- **Our current implementation:** Timeline card had multiple nested containers and gradient borders.
- **Problem:** Heavy visual container competed with the actual note content.
- **Proposed refinement:** Simplify `TimelineConsolidatedCard` to use `NkCard` with hairline border and soft ambient shadow.
- **Expected result:** Content leaps forward; container fades into background.
- **Implementation location:** `lib/widgets/timeline_consolidated_card.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** View consolidated timeline entries.

#### APPLE-061: Timeline Gap Card Micro-Affordance
- **Reference:** Apple Health data gap indicator: minimalist dotted line with subtle time gap label.
- **Our current implementation:** Gap card was a large rectangular box.
- **Problem:** Empty gap looked like an interactive card rather than a timeline pause.
- **Proposed refinement:** Slim down gap card to a whisper-thin 24pt height indicator with muted timestamp.
- **Expected result:** Unobtrusive, elegant timeline gap representation.
- **Implementation location:** `lib/widgets/timeline_gap_card.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect gaps between sessions on the timeline.

#### APPLE-062: History Analytics Card Visual Hierarchy
- **Reference:** Apple Screen Time analytics: prominent total time, clean bar distribution, muted category breakdown.
- **Our current implementation:** Multiple colored badges and numbers competing for attention.
- **Problem:** Cognitive overload when opening History analytics.
- **Proposed refinement:** Establish clear 3-tier hierarchy: (1) Total Focus Time, (2) Bar Chart, (3) Category Rows.
- **Expected result:** Immediate comprehension of daily productivity.
- **Implementation location:** `lib/widgets/history_analytics_card.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Open History and inspect top analytics summary.

#### APPLE-063: Sobriety Streak Shield Card Polish
- **Reference:** Apple Fitness award shields: clean metallic gradient, prominent milestone number.
- **Our current implementation:** Streak card had heavy drop shadow and multiple pill containers.
- **Problem:** Bulky card on home screen.
- **Proposed refinement:** Streamline streak card with continuous squircle border, clean count, and subtle grace day shield.
- **Expected result:** Inspiring, dignified streak tracking badge.
- **Implementation location:** `lib/widgets/home_sobriety_streak_card.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** View sobriety streak card on home screen.

#### APPLE-064: Media Attachment Card Thumbnail Border (Hairline Ring)
- **Reference:** BitChord `FrostedTopBar.kt` avatar: hairline ring prevents light image edges from dissolving into background.
- **Our current implementation:** Photo thumbnails had no boundary stroke.
- **Problem:** White or bright photos bled into light mode card backgrounds.
- **Proposed refinement:** Add `Border.all(color: p.border.withValues(alpha: 0.35), width: 0.5)` to media thumbnails.
- **Expected result:** Crisp thumbnail separation regardless of image brightness.
- **Implementation location:** `lib/widgets/timeline_media_attachment_card.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Attach a white background photo and view in timeline.

#### APPLE-065: Checkpoint Habit Row Completion Strike-Through Physics
- **Reference:** Apple Reminders: subtle fade and delayed line strike when habit is completed.
- **Our current implementation:** Instant binary color flip.
- **Problem:** Abrupt transition without visual satisfaction.
- **Proposed refinement:** Animate completion with 200ms opacity ease to `0.55` and smooth strike-through line.
- **Expected result:** Rewarding, tangible completion feedback.
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart`, `lib/dialogs/checkpoint_session_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Complete a checkpoint habit item.

#### APPLE-066: Project Milestone Reorder List Handle Polish
- **Reference:** Apple iOS reorder handle: three subtle horizontal lines (`reorder_rounded`) with gentle drag lift.
- **Our current implementation:** Reorder handle had high opacity and rough touch feedback.
- **Problem:** Reorder icon distracted from milestone title.
- **Proposed refinement:** Style reorder handle with `p.text3.withValues(alpha: 0.4)` and scale up slightly on drag start.
- **Expected result:** Clean, discoverable reorder affordance.
- **Implementation location:** `lib/dialogs/projects_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Drag and reorder milestones in Projects sheet.

#### APPLE-067: Section Header Action Text Tap Target Expansion
- **Reference:** Apple HIG: trailing section action (e.g. "SEE ALL") has minimum 44x44 touch hit area.
- **Our current implementation:** Plain `GestureDetector` around 13pt text with zero padding.
- **Problem:** Hard to tap "See all" or "Edit" in section headers.
- **Proposed refinement:** Wrap header action text in `ConstrainedBox(minHeight: 44.0)` with horizontal padding.
- **Expected result:** Reliable, effortless header action taps.
- **Implementation location:** `lib/widgets/design_system/nk_card.dart`, `lib/widgets/hig_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap "See all" on Checkpoints and Goals headers.

#### APPLE-068: Inset Divider Color Transition in Dark/Light Mode
- **Reference:** BitChord `Theme.kt`: divider color is `0xFF2C2C2E` (dark) / `0xFFE5E5EA` (light).
- **Our current implementation:** Dividers used `p.border.withValues(alpha: 0.35)`, which could be too faint on non-OLED screens.
- **Problem:** Separators disappeared on low-contrast IPS displays.
- **Proposed refinement:** Guarantee divider color has minimum visible luminance contrast against surface2.
- **Expected result:** Clearly defined, subtle row boundaries across all screen technologies.
- **Implementation location:** `lib/widgets/design_system/nk_card.dart`, `lib/widgets/settings_widgets.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect list dividers on low display brightness.

#### APPLE-069: List Tile Trailing Custom Widget Centering
- **Reference:** Apple HIG: trailing controls are vertically centered on row midline.
- **Our current implementation:** Multi-line rows could push trailing chevrons downward.
- **Problem:** Trailing arrows looked misaligned with multi-line subtitles.
- **Proposed refinement:** Center trailing column on row vertical axis (`crossAxisAlignment: CrossAxisAlignment.center`).
- **Expected result:** Always-balanced trailing icons regardless of subtitle length.
- **Implementation location:** `lib/widgets/design_system/nk_list_tile.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect settings rows with 2-line descriptions.

#### APPLE-070: Card Bottom Spacing Harmony
- **Reference:** Apple HIG Inset Grouped layout: 16pt vertical gap between adjacent grouped cards.
- **Our current implementation:** Margins varied between 6pt, 12pt, and 20pt.
- **Problem:** Inconsistent rhythm between successive grouped sections.
- **Proposed refinement:** Standardize `NkCard` margin to `EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0)`.
- **Expected result:** Perfect, predictable vertical rhythm.
- **Implementation location:** `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll through settings pages with multiple card groups.

---

### Section E: Glass, Translucency & Restrained Layering

#### APPLE-071: Glass Surface Specular Hairline Polish
- **Reference:** BitChord `GLASS_EDGE_WIDTH = 0.5.dp`, `GLASS_EDGE_COLOR = Color.White.copy(alpha = 0.10f)`.
- **Our current implementation:** `Glass` had thick 0.6 border with heavy top-to-bottom white gradient.
- **Problem:** Looked like plastic beveling rather than refined frosted glass.
- **Proposed refinement:** Refine top specular rim to a clean 0.5 hairline stroke with `0.18` alpha on dark, `0.45` on light.
- **Expected result:** Whisper-thin, elegant physical edge highlight.
- **Implementation location:** `lib/widgets/glass.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect floating navigation pill and top dynamic capsule on OLED dark.

#### APPLE-072: Solid Fallback Graceful Degradation in Glass
- **Reference:** BitChord `LiquidGlass.kt`: under "Reduce dynamic blur" or low performance, surface fills solid `surface` without gradients or heavy shadows.
- **Our current implementation:** When blur is disabled, `Glass` still rendered multi-layer ambient drop shadows.
- **Problem:** Muddy black shadow rings on solid OLED surfaces when blur was off.
- **Proposed refinement:** When blur is disabled or high contrast is enabled, render clean solid fill with hairline border and zero shadow clutter.
- **Expected result:** Pristine performance and appearance in battery-saver and low-spec environments.
- **Implementation location:** `lib/widgets/glass.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Disable blur in Display settings; verify clean solid surfaces.

#### APPLE-073: Top Fade Blur Easing Curve
- **Reference:** BitChord `TopFadeBlur.kt`: exponential fade curve preventing abrupt cutoff line.
- **Our current implementation:** Linear gradient blur cutoff in `TopFadeBlur`.
- **Problem:** Visible horizontal line where top gradient ends.
- **Proposed refinement:** Use cubic fade curve (`Curves.easeOutCubic`) across top blur stops.
- **Expected result:** Seamless, invisible transition from blurred top bar to page content.
- **Implementation location:** `lib/widgets/top_fade_blur.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll timeline notes under the top bar; verify smooth dissipation.

#### APPLE-074: Scrim Color Unification for Modal Sheets
- **Reference:** Apple HIG modal sheets: dark neutral scrim `Color.black.withValues(alpha: 0.38)`.
- **Our current implementation:** Some sheets used standard modal barrier `0.54`, others used `0.30`.
- **Problem:** Background darkness changed depending on which sheet opened.
- **Proposed refinement:** Standardize sheet modal barrier to `Colors.black.withValues(alpha: 0.38)`.
- **Expected result:** Consistent, calm ambient dimming.
- **Implementation location:** `lib/dialogs/app_sheet.dart`, `lib/main.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Open multiple sheets and compare background dimming.

#### APPLE-075: Ambient Shadow Spread & Blur Balance in Glass
- **Reference:** Apple HIG macOS/iOS windows: diffuse ambient shadow without sharp edge.
- **Our current implementation:** Glass shadow had `offset: Offset(0, 8)`, creating a downward bias.
- **Problem:** Shadow looked directional rather than ambient.
- **Proposed refinement:** Balance shadow to `offset: Offset(0, 4)`, `blurRadius: 18`, `spreadRadius: 0`.
- **Expected result:** Natural, soft ambient lift around floating pills.
- **Implementation location:** `lib/widgets/glass.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect floating bottom navigation pill.

#### APPLE-076: Dynamic Header Capsule Restrained Blur
- **Reference:** Apple Dynamic Island: solid black in resting state, subtle translucent glow when expanded.
- **Our current implementation:** Dynamic capsule applied continuous backdrop filter even when collapsed.
- **Problem:** Unnecessary GPU fill rate consumption on static text pill.
- **Proposed refinement:** Rest collapsed capsule to solid dark surface; engage backdrop blur only during interactive expansion.
- **Expected result:** Higher battery life, zero dropped frames on scroll.
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Profile GPU frame times while scrolling home screen.

#### APPLE-077: Light Mode Translucent Tint Calibration
- **Reference:** BitChord `LightColors`: glass tint `#FAFAFA` with `0.72` alpha.
- **Our current implementation:** Light mode glass alpha was `0.72` with `#FFFFFF`, which looked slightly washed out over light content.
- **Problem:** Content scrolling under light glass became difficult to distinguish.
- **Proposed refinement:** Use `#F7F7F9` tint at `0.78` alpha on light mode glass surfaces.
- **Expected result:** High-contrast legibility over scrolled text.
- **Implementation location:** `lib/widgets/glass.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll dark text under light mode floating toolbar.

#### APPLE-078: Dark Mode Translucent Tint Calibration
- **Reference:** BitChord `DarkColors`: dark glass tint `#121212` with `0.68` alpha.
- **Our current implementation:** Used `p.surface` directly.
- **Problem:** Amoled theme produced pure black solid fill instead of translucent frost.
- **Proposed refinement:** Tint dark glass with `#121212` at `0.70` alpha on amoled to preserve glass read.
- **Expected result:** True glassmorphic frosted appearance on all dark themes.
- **Implementation location:** `lib/widgets/glass.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** View floating bottom bar on Amoled theme.

#### APPLE-079: Photo Lightbox Translucent Scrim
- **Reference:** Apple Photos lightbox: smooth pitch-black scrim with 0.95 alpha.
- **Our current implementation:** Lightbox had pure opaque black background with hard snap.
- **Problem:** Jarring entrance when opening image attachments.
- **Proposed refinement:** Animate lightbox scrim from `0.0` to `0.95` alpha over 200ms easeOutQuad.
- **Expected result:** Immersive, gentle transition into full-screen photo viewing.
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Tap an attached photo on the timeline.

#### APPLE-080: Glass Edge Radius Clipping Invariant
- **Reference:** BitChord `LiquidGlass.kt`: clip shape matches border shape perfectly to avoid fringing.
- **Our current implementation:** Outer `DecoratedBox` and inner `ClipRRect` could differ by sub-pixel rounding.
- **Problem:** Faint 1px anti-aliasing artifact along curved corners.
- **Proposed refinement:** Share exact `resolvedRadius` between `BoxDecoration` and `ClipRRect`.
- **Expected result:** Razor-sharp, artifact-free corner borders.
- **Implementation location:** `lib/widgets/glass.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect corner edges under 4x magnification.

#### APPLE-081: Eliminate Glass on Flat Settings Rows
- **Reference:** Apple HIG Settings: flat grouped surfaces, no individual row blur.
- **Our current implementation:** `SegmentedSetting` and a few custom settings rows wrapped themselves in `Glass`.
- **Problem:** Visual clutter and conflicting glass-over-glass layers.
- **Proposed refinement:** Remove `Glass` wrappers from inside settings dialogs; use flat `NkCard` with `surface2`.
- **Expected result:** Clean, calm settings hierarchy.
- **Implementation location:** `lib/widgets/settings_widgets.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Open Settings and verify flat, calm card backgrounds.

#### APPLE-082: Activity Heatmap Card Surface Treatment
- **Reference:** Apple GitHub / Git-style activity graphs: clean flat card with crisp grid cells.
- **Our current implementation:** Wrapped in heavy border with high opacity.
- **Problem:** Heatmap card competed with surrounding habit cards.
- **Proposed refinement:** Use standard `NkCard` container with hairline border.
- **Expected result:** Elegant habit consistency visualization.
- **Implementation location:** `lib/widgets/activity_heatmap_widget.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** View habit consistency heatmap in Checkpoints.

#### APPLE-083: Coachmark Tooltip Translucent Bubble
- **Reference:** Apple HIG onboarding coachmarks: translucent squircle capsule with subtle arrow.
- **Our current implementation:** High opacity tooltip with harsh shadow.
- **Problem:** Overpowered the interface elements it was explaining.
- **Proposed refinement:** Style coachmark with `0.85` translucent dark fill, hairline outline, and soft fade.
- **Expected result:** Helpful, polite guidance tooltips.
- **Implementation location:** `lib/widgets/home_coachmark_tooltip.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Trigger onboarding tooltip on home screen.

#### APPLE-084: Zen Day Gauge Ambient Glow Restraint
- **Reference:** Apple Watch Activity rings: crisp vector arc with subtle glow only at completion.
- **Our current implementation:** Gauge had strong permanent shadow.
- **Problem:** Blur radius distracted from clean numerical day progress.
- **Proposed refinement:** Confine ring glow strictly to 100% completion state.
- **Expected result:** Minimal, precise circadian day progress ring.
- **Implementation location:** `lib/widgets/zen_day_gauge.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect Zen Day Gauge at 50% and 100% progress.

#### APPLE-085: Bottom Nav Bar Edge Hairline Sync
- **Reference:** BitChord `FloatingBottomBar.kt`: hairline border matches top floating chrome.
- **Our current implementation:** Bottom toolbar border had different opacity than top capsule.
- **Problem:** Mismatched chrome edge styling between top and bottom of screen.
- **Proposed refinement:** Sync bottom toolbar border to `NkBorders.hairline` and `GLASS_EDGE_COLOR`.
- **Expected result:** Cohesive chrome framing top and bottom of viewport.
- **Implementation location:** `lib/widgets/toolbar.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Compare top capsule and bottom toolbar border stroke on device.

---

### Section F: Navigation, Floating Bottom Bar & Top Bars

#### APPLE-086: Bottom Toolbar 4-Pass Bounce Elimination
- **Reference:** BitChord motion principle: "Damping 0.72 settles on the second approach — one soft pass beyond the mark and done — which is the difference between bouncy and alive."
- **Our current implementation:** `Toolbar` executed a 4-pass bouncing tween (`-8, +6, -3, 0`) over 700ms on goal change.
- **Problem:** Cartoonish, exaggerated bouncing that felt unrefined.
- **Proposed refinement:** Replace multi-pass bounce sequence with a single subtle spring animation (300ms, damping 0.75, offset max 3px).
- **Expected result:** Alive, dignified tactile feedback on goal switch.
- **Implementation location:** `lib/widgets/toolbar.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Switch active goals in toolbar; verify single, subtle arrival.

#### APPLE-087: Bottom Toolbar Pill Proportions & Geometry
- **Reference:** BitChord `FloatingBottomBar.kt`: `NAV_BAR_GUTTER = 19.dp`, `NAV_BAR_LIFT = 6.dp`, `PILL_INSET = 4.dp`.
- **Our current implementation:** Toolbar used `width: math.min(width - 48, 318)` with ad-hoc padding.
- **Problem:** Width clamped rigidly on large displays, leaving awkward empty space.
- **Proposed refinement:** Use responsive width constraints (`maxWidth: 360`, horizontal margin `19.0`) with `4.0` pill inset.
- **Expected result:** Beautifully balanced floating bottom bar across all screen form factors.
- **Implementation location:** `lib/widgets/toolbar.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Test toolbar on 360dp phone, 412dp phone, and tablet emulator.

#### APPLE-088: Floating Back & Action Circles (44pt Apple Size)
- **Reference:** BitChord `TOP_CONTROL_SIZE = 44.dp` for circular floating back and action controls.
- **Our current implementation:** Sheet header circle buttons were 32x32 without 44x44 tap target padding.
- **Problem:** Fails accessibility touch target guidelines and felt undersized next to finger taps.
- **Proposed refinement:** Standardize circular header buttons to 40x40 visual badge inside 44x44 minimum interactive slot.
- **Expected result:** Effortless tap targeting on back and close buttons.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap header close and back buttons in all sheets.

#### APPLE-089: Predictive Back Swipe Gesture Harmony (Android 14/15)
- **Reference:** Android 14/15 Predictive Back: smooth scale down and peek behind current sheet.
- **Our current implementation:** Basic predictive back peek existed in `predictive_back_peek.dart`, but was not enabled on all sheet routes.
- **Problem:** Back gesture popped abruptly on certain sub-pages.
- **Proposed refinement:** Integrate predictive back handler across all settings sub-pages and modal sheets.
- **Expected result:** Fluid, native Android system gesture harmony.
- **Implementation location:** `lib/widgets/predictive_back_peek.dart`, `lib/dialogs/settings_dialog.dart`.
- **Complexity:** Medium.
- **Priority:** High.
- **Risk:** Requires testing on both 3-button and gesture navigation.
- **Verification:** Swipe back from left edge on Android 14+ device.

#### APPLE-090: Sheet Header Title Fade-In on Scroll
- **Reference:** BitChord `FrostedTopBar.kt`: large in-page header owns title at rest; centered small title fades in as list scrolls past large title.
- **Our current implementation:** `AppSheet` had custom offset math (`(offset - 45) / 20`), but threshold wasn't calibrated for all font scales.
- **Problem:** Small title sometimes overlapped large title or faded in prematurely.
- **Proposed refinement:** Calibrate title fade-in threshold to trigger precisely when large title bottom clears top bar divider.
- **Expected result:** Flawless title continuity during scrolling.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll History and Settings sheets and observe header title fade.

#### APPLE-091: Scroll Position Preservation on Deep Settings Navigation
- **Reference:** BitChord & Apple HIG: returning from sub-page restores exact scroll offset.
- **Our current implementation:** Handled via `AppScrollState`, but required manual keys on every sub-page.
- **Problem:** Occasional scroll reset when navigating through deep diagnostics settings.
- **Proposed refinement:** Ensure automatic scroll key persistence across all 35 settings sub-dialogs.
- **Expected result:** Zero lost scroll positions.
- **Implementation location:** `lib/utils/scroll_state_preserver.dart`, `lib/dialogs/settings_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll deep into Display settings, open a sub-sheet, pop back; verify scroll position maintained.

#### APPLE-092: Bottom Navigation Bar Gesture Inset Clearance
- **Reference:** BitChord `floatingBarInsets`: `navigationBars.union(WindowInsets(bottom = GESTURE_BAR_FLOOR))` (15dp floor).
- **Our current implementation:** If gesture bar was hidden, toolbar could touch bottom screen edge.
- **Problem:** Toolbar dropped onto bezel on phones with hidden navigation bar.
- **Proposed refinement:** Enforce minimum bottom margin floor of 16.0dp even when system gesture bar inset is 0.
- **Expected result:** Floating toolbar always floats comfortably above device bottom edge.
- **Implementation location:** `lib/widgets/toolbar.dart`, `lib/screens/note_kar_home.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Test with gesture navigation bar hidden in Android system settings.

#### APPLE-093: Dynamic Capsule Tap-to-Expand Spring Kinetics
- **Reference:** Apple Dynamic Island spring curve (stiffness: 300, damping: 28).
- **Our current implementation:** Used `Cubic(0.2, 0.9, 0.3, 1.0)`.
- **Problem:** Decent easing, but lacked tactile settling.
- **Proposed refinement:** Calibrate expansion duration to 280ms with `Curves.easeOutCubic`.
- **Expected result:** Snappy, delightful expansion of header capsule.
- **Implementation location:** `lib/widgets/dynamic_header_capsule.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Tap top dynamic capsule on home screen.

#### APPLE-094: Category Pills Horizontal Drag & Scroll Bounds
- **Reference:** BitChord `fadingEdges`: horizontal scroll indicators fade out smoothly at edges with more content.
- **Our current implementation:** Category pills scrolled horizontally with hard cutoffs at screen edges.
- **Problem:** Rightmost category pill abruptly cut off without indicating more items.
- **Proposed refinement:** Apply soft 16dp horizontal fading edges to category pill scroll view.
- **Expected result:** Elegant visual cue that horizontal content continues.
- **Implementation location:** `lib/widgets/home_category_pills.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Scroll category pills horizontally on home screen.

#### APPLE-095: Home Screen Quick-Action Toolbar Capsule Sizing
- **Reference:** BitChord bottom actions: 44pt touch slot, clean 18pt icons.
- **Our current implementation:** `HomeMinimalToolbarCapsule` had 48pt height with tight horizontal spacing.
- **Problem:** Icons crowded center of the capsule.
- **Proposed refinement:** Space icons evenly with `MainAxisAlignment.spaceEvenly` inside balanced capsule.
- **Expected result:** Clean, proportionate minimal toolbar.
- **Implementation location:** `lib/widgets/home_minimal_toolbar_capsule.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Toggle Minimal Toolbar in Display settings.

#### APPLE-096: Sheet Dismiss Drag Resistance (Elastic Damping)
- **Reference:** Apple modal sheet drag-to-dismiss: resistant travel beyond pull threshold.
- **Our current implementation:** Standard velocity check popped sheet abruptly.
- **Problem:** Hard snap closed without physical damping sensation.
- **Proposed refinement:** Apply elastic drag resistance `(1f + (drag - threshold) * 0.35f)` past dismiss threshold.
- **Expected result:** Natural, weighted sheet dismissal.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Drag down on sheet header to dismiss.

#### APPLE-097: Top Bar Title Tap to Scroll-To-Top
- **Reference:** Apple iOS convention: tapping top header scrolls active list to top.
- **Our current implementation:** Supported on `AppSheetLargeTitle`, but some sub-pages lacked handler hook.
- **Problem:** Inconsistent tap-to-scroll behavior across sub-pages.
- **Proposed refinement:** Connect `_handleTitleTap` to `PrimaryScrollController` universally across all sheets.
- **Expected result:** Tapping any sheet title scrolls smoothly to top.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Scroll down in History, tap title "History", verify smooth scroll to top.

#### APPLE-098: Mode Switcher Tabular Transition (Single vs Two-Way)
- **Reference:** BitChord playback mode switch: smooth cross-fade with zero layout jump.
- **Our current implementation:** Mode button replaced label text instantly.
- **Problem:** Slight horizontal jump when switching between 'Single' and 'Two-Way'.
- **Proposed refinement:** Fixed width text container with smooth animated cross-fade (`180ms`).
- **Expected result:** Rock-solid mode toggle without layout stutter.
- **Implementation location:** `lib/widgets/toolbar.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Tap Mode button in toolbar.

#### APPLE-099: Smart Search Chips Bar Horizontal Clearance
- **Reference:** Apple Spotlight filters: chips float comfortably below search bar with 8pt gap.
- **Our current implementation:** Chips sat tight against search bar bottom border.
- **Problem:** Crowded search interface.
- **Proposed refinement:** Add `NkSpacing.sm` (8.0pt) vertical breathing room between search bar and chips.
- **Expected result:** Clean, spacious search experience.
- **Implementation location:** `lib/widgets/smart_search_chips_bar.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open Search dialog and inspect chip clearance.

#### APPLE-100: Back Button Hit Slop Extension
- **Reference:** Apple HIG: back buttons have extended hit slop into leading screen edge.
- **Our current implementation:** Back button hit area was strictly bounded to its icon box.
- **Problem:** Taps at the very left edge of the screen were missed.
- **Proposed refinement:** Extend `hitTestBehavior: HitTestBehavior.opaque` into leading gutter.
- **Expected result:** 100% reliable back button presses on device edges.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap leading edge beside back arrow.

#### APPLE-101: Floating Timer Bubble Docking Alignment
- **Reference:** Apple AssistiveTouch: docks into a slim edge line when resting.
- **Our current implementation:** Floating bubble rested on screen border.
- **Problem:** Slightly obscured content on narrow screens.
- **Proposed refinement:** Auto-fade bubble to 0.4 opacity when stationary for 3 seconds.
- **Expected result:** Unobtrusive, always-accessible timer bubble.
- **Implementation location:** `lib/dialogs/settings/targets_projects_settings_page.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Enable floating bubble and observe idle dimming.

#### APPLE-102: System Bar Contrast Enforcement Invariant
- **Reference:** BitChord `SystemBarIcons.kt`: status bar icons follow actual painted content, not system theme setting.
- **Our current implementation:** Handled in `main.dart`, but some modal sheets reset status bar brightness.
- **Problem:** White status bar icons over white modal sheet headers.
- **Proposed refinement:** Enforce `statusBarIconBrightness` dynamically based on current sheet background luminance.
- **Expected result:** Status bar time and battery icons always 100% legible.
- **Implementation location:** `lib/main.dart`, `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Open sheets in both light and dark themes; verify status bar clock visibility.

---

### Section G: Modal Sheets, Dialogs & Insets

#### APPLE-103: Sheet Max Width Constraint on Wide Screens (Tablet / Foldable)
- **Reference:** Apple iPadOS / Android Foldable HIG: sheets do not stretch full-width across 1000px screens.
- **Our current implementation:** Docked sheets stretched to 720px, but some dialogs stretched full viewport.
- **Problem:** Ridiculously wide rows on tablets and unfolded foldables.
- **Proposed refinement:** Constrain sheet width to `math.min(MediaQuery.sizeOf(context).width, 580.0)` centered on screen.
- **Expected result:** Beautifully proportioned modal sheets on foldables and tablets.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Test on tablet emulator or landscape orientation.

#### APPLE-104: Sheet Drag Handle Semantics & Accessibility
- **Reference:** TalkBack guidelines: sheet grabber announces "Dismiss sheet, button".
- **Our current implementation:** Grabber had `Semantics` label but missing button trait in some dialogs.
- **Problem:** Screen reader users didn't recognize grabber as a dismiss affordance.
- **Proposed refinement:** Ensure grabber has `Semantics(label: 'Dismiss sheet', button: true, onTap: pop)`.
- **Expected result:** Accessible, voice-navigable modal sheets.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Test with TalkBack on sheet grabber.

#### APPLE-105: Bottom Safe Area Inset Padding Harmony
- **Reference:** Android 15 edge-to-edge window insets: content clears gesture navigation bar.
- **Our current implementation:** `removeBottomPadding` flag had ad-hoc padding math.
- **Problem:** Content occasionally collided with system navigation gesture bar on Android 14/15.
- **Proposed refinement:** Use `MediaQuery.paddingOf(context).bottom + 16.0` as standard bottom sheet content padding.
- **Expected result:** Generous, comfortable bottom clearance for all sheet buttons.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Verify bottom button clearance on device with gesture navigation.

#### APPLE-106: Dialog Alert Action Button Layout (Vertical Stacking on Narrow Widths)
- **Reference:** Apple alert dialogs: two buttons sit side-by-side; if labels are long, they stack vertically.
- **Our current implementation:** Two buttons forced into a row, causing text truncation on long localized strings.
- **Problem:** Truncated button text in German, Hindi, or Spanish translations.
- **Proposed refinement:** Implement responsive button layout: side-by-side when fitting, stacked vertically if text wraps.
- **Expected result:** Zero truncated button labels across all languages.
- **Implementation location:** `lib/dialogs/backup_dialogs.dart`, `lib/dialogs/reset_sheets.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Test with long localized strings in Spanish/German.

#### APPLE-107: Sheet Backdrop Scrim Tap to Dismiss Reliability
- **Reference:** Apple HIG: tapping outside modal sheet dismisses it immediately.
- **Our current implementation:** Some custom sheets intercepted taps outside without popping.
- **Problem:** Users felt trapped when tapping outside didn't dismiss.
- **Proposed refinement:** Ensure `barrierDismissible: true` and modal barrier gestures consistently pop sheets.
- **Expected result:** 100% reliable outside-tap dismissal.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap background dimming on any sheet to dismiss.

#### APPLE-108: Note Preview Sheet Rich Markdown Presentation
- **Reference:** Apple Notes preview: generous line spacing (1.45), clean headers, inline image cards.
- **Our current implementation:** Note preview sheet was cramped with minimal line height.
- **Problem:** Dense walls of text in preview mode.
- **Proposed refinement:** Increase preview line height to 1.45, font size 16pt, with breathable paragraph spacing.
- **Expected result:** Delightful, magazine-like note reading experience.
- **Implementation location:** `lib/dialogs/note_preview_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Preview a long note.

#### APPLE-109: Daily Wrap-Up Sheet Stat Card Proportions
- **Reference:** Apple Health summary: four balanced metric tiles in 2x2 grid.
- **Our current implementation:** Wrap-up cards had uneven vertical heights.
- **Problem:** Ragged bottom edges on summary cards.
- **Proposed refinement:** Standardize wrap-up metric cards to uniform aspect ratio with centered icons.
- **Expected result:** Symmetrical, elegant daily wrap-up dashboard.
- **Implementation location:** `lib/dialogs/daily_wrapup_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Trigger daily wrap-up sheet.

#### APPLE-110: Time Reflection Sheet Circadian Clock Centering
- **Reference:** Apple Bedtime / Sleep schedule: circular clock centered with soft ambient ticks.
- **Our current implementation:** Circadian ring was slightly off-center in landscape orientation.
- **Problem:** Asymmetrical visual balance.
- **Proposed refinement:** Center circadian ring strictly inside constrained aspect ratio box.
- **Expected result:** Perfectly centered reflection clock.
- **Implementation location:** `lib/dialogs/time_reflection_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open Time Reflection sheet in portrait and landscape.

#### APPLE-111: Sunday Dispatch Sheet Typography & Margin
- **Reference:** Apple Books / editorial dispatch: serif or clean sans headline with generous margins.
- **Our current implementation:** Sunday Dispatch sheet had tight 12pt horizontal margins.
- **Problem:** Read like a settings list rather than a weekly reflection dispatch.
- **Proposed refinement:** Increase horizontal padding to 24pt with 18pt title and 1.5 line height.
- **Expected result:** Calming, weekly editorial digest.
- **Implementation location:** `lib/dialogs/sunday_dispatch_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open Sunday Dispatch sheet.

#### APPLE-112: Urge Surfing Dialog Timer Ring Animation
- **Reference:** Apple Breathe / Mindfulness app: expanding and contracting mandala ring.
- **Our current implementation:** Basic countdown text without visual breathing pacing.
- **Problem:** Missed opportunity for calming mindfulness guidance.
- **Proposed refinement:** Add gentle expanding/contracting ring animation synchronized with 4-second breathing cycle.
- **Expected result:** Genuine calming utility during urge surfing sessions.
- **Implementation location:** `lib/dialogs/urge_surfing_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Start an Urge Surfing session and follow the breathing ring.

#### APPLE-113: Shareable Milestone Card Layout & Export Resolution
- **Reference:** Apple Fitness award sharing: crisp 1080x1920 export card with metallic badge.
- **Our current implementation:** Shareable milestone sheet was sized for screen preview only.
- **Problem:** Exported card looked blurry when shared to social media or messaging apps.
- **Proposed refinement:** Render export canvas at 3x pixel ratio with high-resolution vector assets.
- **Expected result:** Razor-sharp shareable milestone cards.
- **Implementation location:** `lib/dialogs/shareable_milestone_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Generate and export a milestone achievement card.

#### APPLE-114: Peer Comparison Sheet Privacy Shield
- **Reference:** Apple Health Sharing: clear privacy disclaimer explaining zero personal data leakage.
- **Our current implementation:** Generic explanation text at bottom of sheet.
- **Problem:** Users questioned whether their data was being uploaded.
- **Proposed refinement:** Add prominent "100% Local Peer Verification" shield badge at top of sheet.
- **Expected result:** Instant user trust and clarity.
- **Implementation location:** `lib/dialogs/peer_comparison_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Open Peer Comparison sheet.

#### APPLE-115: Vault Password Dialog PIN Keypad Sizing
- **Reference:** Apple iOS Lock Screen keypad: 72x72 circular buttons with generous 16pt gap.
- **Our current implementation:** Keypad buttons were 54x54 with tight spacing.
- **Problem:** Frequent mistypes on numeric PIN pad.
- **Proposed refinement:** Increase keypad buttons to 64x64 with 14pt gap and tactile touch scale.
- **Expected result:** Effortless, confident PIN entry.
- **Implementation location:** `lib/dialogs/vault_password_dialog.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Unlock vault with PIN pad.

#### APPLE-116: Official Bulletins Sheet Typography & Timestamp
- **Reference:** Apple News / Release bulletins: bold headline, relative date stamp, clean hairline separator.
- **Our current implementation:** Bulletins had unformatted raw ISO timestamps.
- **Problem:** Raw timestamps looked developer-focused rather than consumer-friendly.
- **Proposed refinement:** Format bulletin timestamps into friendly relative dates (e.g. "3 days ago").
- **Expected result:** Professional, polished bulletin feed.
- **Implementation location:** `lib/dialogs/official_bulletins_sheet.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open Official Bulletins sheet.

#### APPLE-117: Changelog Dialog Version Badge Styling
- **Reference:** Apple App Store "What's New": bold version number with release tag chip.
- **Our current implementation:** Plain text version heading.
- **Problem:** Blended into release notes text.
- **Proposed refinement:** Style version header with accent chip badge and bold title.
- **Expected result:** Scannable, celebratory changelog.
- **Implementation location:** `lib/dialogs/changelog_dialog.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open Changelog dialog from Settings.

#### APPLE-118: Smart Trim Sheet Waveform Visualizer Polish
- **Reference:** Apple Voice Memos trim tool: clean audio waveform bars with yellow/accent trim handles.
- **Our current implementation:** Basic bar chart representation.
- **Problem:** Trim handles were hard to drag accurately.
- **Proposed refinement:** Render smoothed waveform bars with prominent 24pt draggable trim handles.
- **Expected result:** Tactile, precise audio trimming.
- **Implementation location:** `lib/dialogs/smart_trim_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Record audio note and open Smart Trim sheet.

---

### Section H: Motion, Springs, Easing & Physics

#### APPLE-119: Single-Pass Spring Motion Curve (`NkCurves.appleSpring`)
- **Reference:** BitChord `GlassSpring`: `dampingRatio = 0.72f, stiffness = 320f` ("settles on the second approach — one soft pass beyond the mark and done — which is the difference between bouncy and alive").
- **Our current implementation:** Varied curves across widgets (`elasticOut`, `bounceOut`, `fastOutSlowIn`).
- **Problem:** Jarring differences in motion feel between different components.
- **Proposed refinement:** Standardize `NkCurves.appleSpring = Cubic(0.25, 0.9, 0.35, 1.0)` and spring physics parameters for all layout and indicator travel.
- **Expected result:** Consistent, organic, premium physical movement across the entire app.
- **Implementation location:** `lib/theme/app_tokens.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Test tab indicators, sheet openings, and button presses.

#### APPLE-120: Micro-Scale Press Duration Tuning (120ms Fast Return)
- **Reference:** BitChord pressed states: instant touch-down, 120ms smooth return on touch-up.
- **Our current implementation:** `PressableScale` used 150-200ms with linear easing.
- **Problem:** Felt sluggish or sticky under rapid tapping.
- **Proposed refinement:** Set press scale to 100ms down, 140ms up with `Curves.easeOutCubic`.
- **Expected result:** Immediate, responsive tactile sensation on every tap.
- **Implementation location:** `lib/widgets/pressable_scale.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap rapidly across home screen buttons.

#### APPLE-121: Sheet Entrance Easing Calibration (400ms Smooth Curve)
- **Reference:** Apple HIG sheet slide-up: 400ms cubic bezier with swift start and gentle deceleration.
- **Our current implementation:** Flutter default bottom sheet animation (fastOutSlowIn).
- **Problem:** Can feel abrupt at the start of travel.
- **Proposed refinement:** Apply `Curves.easeOutCubic` across sheet modal transitions.
- **Expected result:** Silky smooth sheet presentation.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Open History and Settings sheets.

#### APPLE-122: Eliminate High-Frequency Sensor Jitter in Parallax
- **Reference:** BitChord sensor handling: throttled vsync alignment.
- **Our current implementation:** Accelerometer listener streamed at up to 200 Hz into setState without throttling.
- **Problem:** High CPU churn and battery consumption on 120Hz displays.
- **Proposed refinement:** Throttle sensor updates to 60fps frame rate matching vsync with low-pass filter.
- **Expected result:** Silky smooth parallax with zero battery waste.
- **Implementation location:** `lib/screens/note_kar_home.dart`, `lib/widgets/clock_face.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Profile CPU usage with parallax enabled.

#### APPLE-123: Page Transition Continuity (Slide & Fade)
- **Reference:** Apple iOS navigation push: right-to-left slide with left page subtle scale back (0.95x).
- **Our current implementation:** Default MaterialPageRoute in some sub-dialogs.
- **Problem:** Material vertical zoom clashed with horizontal back swipe gestures.
- **Proposed refinement:** Use CupertinoPageTransitionsBuilder / horizontal slide-and-fade for sub-pages.
- **Expected result:** Natural spatial continuity during navigation.
- **Implementation location:** `lib/main.dart`, `lib/dialogs/settings_dialog.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Navigate into Settings sub-pages.

#### APPLE-124: Milestone Celebration Confetti Particle Physics
- **Reference:** BitChord celebratory animations: gentle gravity, slow rotation, no jarring pops.
- **Our current implementation:** Confetti burst was brief and abruptly vanished.
- **Problem:** Lacked celebratory emotional impact.
- **Proposed refinement:** Tune confetti physics with realistic air resistance, gentle drift, and 2.5s duration.
- **Expected result:** Joyful, rewarding milestone celebration.
- **Implementation location:** `lib/widgets/milestone_celebration_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Complete a milestone and watch celebration confetti.

#### APPLE-125: Zen Doodle Splash Expansion Easing
- **Reference:** Apple Watch Mindfulness expansion animation: smooth sinusoidal breath curve.
- **Our current implementation:** Linear radial expansion.
- **Problem:** Felt mechanical rather than organic.
- **Proposed refinement:** Apply sinusoidal easeInOut curve to doodle splash expansion.
- **Expected result:** Meditative, calming visual transition.
- **Implementation location:** `lib/widgets/zen_doodle_splash.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Trigger Zen doodle splash on app start.

#### APPLE-126: Category Pill Selection Traveling Indicator
- **Reference:** BitChord `PillSegmentedControl.kt`: indicator smoothly travels along track.
- **Our current implementation:** Category pill selection jumped with instant background color swap.
- **Problem:** Abrupt visual pop without continuity.
- **Proposed refinement:** Animate selection change with smooth 180ms background color and scale transition.
- **Expected result:** Fluid category switching on home screen.
- **Implementation location:** `lib/widgets/home_category_pills.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Tap between different category pills.

#### APPLE-127: Clock Hand Movement Physics in Live Tracking
- **Reference:** Apple Clock app: smooth continuous sweep rather than rigid ticking.
- **Our current implementation:** Stepped 1-second ticks in session clock face.
- **Problem:** Rigid jumping hand.
- **Proposed refinement:** Support smooth continuous sweep animation option on clock second hand.
- **Expected result:** Luxurious chronometer aesthetic.
- **Implementation location:** `lib/widgets/clock_face.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Observe clock face during active focus session.

#### APPLE-128: Checkpoint Quick Bar Expansion Spring
- **Reference:** Apple Control Center: modules expand with dampened spring physics.
- **Our current implementation:** Height animated with basic easeInOut.
- **Problem:** Lacked physical weight during expansion.
- **Proposed refinement:** Apply single-pass spring curve to quick-bar drawer expansion.
- **Expected result:** Tactile, weighted drawer opening.
- **Implementation location:** `lib/widgets/checkpoints_quick_bar.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Expand and collapse checkpoints quick-bar.

#### APPLE-129: Swipeable Card Bed Threshold & Reset Physics
- **Reference:** Apple Mail swipe actions: snap to action threshold, smooth spring reset on release.
- **Our current implementation:** Linear drag tracking in `SwipeableCardBed`.
- **Problem:** Could feel loose or get stuck halfway.
- **Proposed refinement:** Implement magnetic snap-to-threshold with spring reset (`stiffness: 400`).
- **Expected result:** Crisp, dependable swipe-to-delete on timeline items.
- **Implementation location:** `lib/widgets/swipeable_card_bed.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Swipe a timeline item left to reveal delete action.

#### APPLE-130: Respect "Reduce Motion" Across All Custom Animations
- **Reference:** Apple Accessibility & BitChord: zero motion when system animator duration is 0 or user toggles "Reduce motion".
- **Our current implementation:** Handled in primary screens, but some custom tweens bypassed check.
- **Problem:** Discomfort for motion-sensitive users.
- **Proposed refinement:** Enforce `reduceMotion` check in all custom animations, falling back to instant cross-fades.
- **Expected result:** 100% compliant accessibility motion restraint.
- **Implementation location:** `lib/widgets/toolbar.dart`, `lib/widgets/pressable_scale.dart`, `lib/widgets/dynamic_header_capsule.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Enable "Reduce motion" in Display settings; verify all animations become instant.

#### APPLE-131: Audio Waveform Visualizer Ballistics
- **Reference:** Apple Voice Memos: dynamic audio metering with rapid peak attack and gentle exponential decay.
- **Our current implementation:** Audio recording waveform reacted with linear height jumps.
- **Problem:** Jittery, jagged waveform bars.
- **Proposed refinement:** Implement peak attack (30ms) and exponential decay (150ms) smoothing.
- **Expected result:** Professional studio-grade audio visualization.
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Record a voice note and observe waveform responsiveness.

#### APPLE-132: Circular Day View Scrubbing Feedback
- **Reference:** Apple Watch dial scrubbing: buttery 60fps tracking under finger.
- **Our current implementation:** Timeline scrubbing occasionally stuttered on dense history days.
- **Problem:** Lag when dragging finger across 24-hour circular dial.
- **Proposed refinement:** Optimize custom painter repaint boundary and throttle repaint calls.
- **Expected result:** Zero-lag scrubbing across full 24-hour history.
- **Implementation location:** `lib/widgets/history_calendar_view.dart`, `lib/dialogs/history_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Drag finger around circular 24h history dial.

#### APPLE-133: Lightbox Pinch-to-Zoom Inertia
- **Reference:** Apple Photos: fluid double-tap zoom and elastic boundary bounce.
- **Our current implementation:** InteractiveViewer had basic boundary clamping.
- **Problem:** Hard stop when reaching zoom limits.
- **Proposed refinement:** Enable soft boundary elasticity on photo lightbox viewer.
- **Expected result:** Natural, tactile photo inspection.
- **Implementation location:** `lib/widgets/photo_lightbox_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Pinch to zoom on photo attachment in lightbox.

#### APPLE-134: Goal Progress Ring Fill Animation
- **Reference:** Apple Fitness rings: smooth circular arc growth with rounded endcap.
- **Our current implementation:** Instant progress ring redraw.
- **Problem:** Lack of visual celebration when milestone completes.
- **Proposed refinement:** Animate goal progress ring fill over 350ms easeOutCubic with rounded stroke caps.
- **Expected result:** Inspiring, smooth goal progress updates.
- **Implementation location:** `lib/dialogs/goals_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Check off a milestone in Goals and watch the progress ring animate.

#### APPLE-135: Hashtag Suggestion Overlay Entrance Animation
- **Reference:** Apple Auto-complete popover: subtle fade-and-rise (8pt) above keyboard.
- **Our current implementation:** Abrupt appearance of suggestion chips.
- **Problem:** Sudden visual pop over text field.
- **Proposed refinement:** Animate hashtag suggestions overlay with 150ms fade and 6pt upward slide.
- **Expected result:** Polite, seamless tag suggestions while typing.
- **Implementation location:** `lib/widgets/hashtag_suggestion_overlay.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Type `#` in note editor and observe suggestion chip entrance.

---

### Section I: Haptics, Gestures & Micro-Interactions

#### APPLE-136: Semantic Haptic Differentiation (ToggleOn vs ToggleOff)
- **Reference:** BitChord `Haptics.kt`: distinct crisp ticks for toggle on vs toggle off.
- **Our current implementation:** Called generic `selectionClick` indiscriminately.
- **Problem:** Lacked tactile distinction between turning a setting on vs off.
- **Proposed refinement:** Implement semantic haptics: sharp medium impact for toggle-on, light click for toggle-off.
- **Expected result:** Intuitive mechanical confirmation even with eyes off screen.
- **Implementation location:** `lib/utils/app_utils.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Toggle switches in Settings and feel haptic difference between ON and OFF.

#### APPLE-137: Milestone Completion Heavy Impact Haptic
- **Reference:** Apple Activity: distinct celebratory double-tap haptic upon closing rings.
- **Our current implementation:** Single light selection click.
- **Problem:** Understated tactile feedback for a major user achievement.
- **Proposed refinement:** Trigger `HapticFeedback.heavyImpact()` followed by `HapticFeedback.lightImpact()` on milestone completion.
- **Expected result:** Thrilling, tactile celebration in user's hand.
- **Implementation location:** `lib/utils/app_utils.dart`, `lib/widgets/milestone_celebration_dialog.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Complete a goal milestone and feel celebratory haptic pattern.

#### APPLE-138: Segmented Control Tick Haptic on Index Change
- **Reference:** BitChord `PillSegmentedControl.kt`: `HapticFeedbackType.TextHandleMove` on index change.
- **Our current implementation:** Some segmented controls triggered no haptics.
- **Problem:** Silent segment change lacked physical slider feel.
- **Proposed refinement:** Trigger light selection click strictly when selected segment index changes.
- **Expected result:** Subtle tactile tick as selection slides under finger.
- **Implementation location:** `lib/widgets/design_system/nk_pill_segmented_control.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Slide across segmented control options.

#### APPLE-139: Sheet Drag Threshold Dismissal Haptic
- **Reference:** Apple modal sheet: crisp haptic feedback at exact point drag distance guarantees dismiss.
- **Our current implementation:** Sheet dismissed silently without boundary indicator.
- **Problem:** User unsure whether letting go will dismiss or snap back.
- **Proposed refinement:** Fire `HapticFeedback.lightImpact()` when drag crosses 35% dismiss threshold.
- **Expected result:** Intuitive tactile cue that sheet is ready to release.
- **Implementation location:** `lib/dialogs/app_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Drag down on sheet header; feel tactile cue at dismiss threshold.

#### APPLE-140: Long-Press Context Menu Haptic Response
- **Reference:** BitChord `HeldContextMenu.kt`: medium haptic pulse at exact moment item lifts.
- **Our current implementation:** Delayed haptic after menu was already visible.
- **Problem:** Disconnected tactile timing.
- **Proposed refinement:** Fire `HapticFeedback.mediumImpact()` synchronized with touch hold recognition.
- **Expected result:** Feels as though the card physically pops out of the screen.
- **Implementation location:** `lib/widgets/pressable_scale.dart`, `lib/widgets/timeline_single_tile.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Long press on a timeline note.

#### APPLE-141: Slider Value Detent Haptics
- **Reference:** Apple HIG sliders: light tick when passing landmark intervals (e.g. 15m, 30m, 45m).
- **Our current implementation:** Silent continuous slider.
- **Problem:** Difficult to land precisely on target values without looking closely.
- **Proposed refinement:** Fire light haptic tick at 15-minute detents on session duration slider.
- **Expected result:** Effortless, eyes-free slider adjustment.
- **Implementation location:** `lib/dialogs/manual_entry_dialog.dart`, `lib/widgets/settings_widgets.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Slide session duration slider through 15m intervals.

#### APPLE-142: Delete Confirmation Guard Haptic
- **Reference:** Apple iOS destructive operations: distinct warning haptic on delete dialog.
- **Our current implementation:** Standard click.
- **Problem:** No tactile warning of irreversible data modification.
- **Proposed refinement:** Trigger `HapticFeedback.heavyImpact()` when opening permanent delete dialog.
- **Expected result:** Subconscious cautionary cue reinforcing data safety.
- **Implementation location:** `lib/dialogs/reset_sheets.dart`, `lib/dialogs/settings/trash_bin_settings_page.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Tap "Empty Trash" and note warning haptic.

#### APPLE-143: Pull-to-Refresh Haptic Detent
- **Reference:** BitChord `FrostedTopBar.kt` `RefreshPuck`: light click when pull passes trigger threshold.
- **Our current implementation:** Silent refresh trigger.
- **Problem:** User unsure how far down to pull.
- **Proposed refinement:** Fire `HapticFeedback.mediumImpact()` when pull-to-refresh crosses trigger distance.
- **Expected result:** Clear tactile confirmation to release finger.
- **Implementation location:** `lib/screens/note_kar_home.dart`, `lib/dialogs/history_dialog.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Pull down to refresh timeline on home screen.

#### APPLE-144: Audio Scrubber Scrubbing Tick
- **Reference:** Apple Voice Memos scrubber: periodic micro-ticks during audio scrubbing.
- **Our current implementation:** Silent dragging.
- **Problem:** Lacked tactile tape-deck scrubbing sensation.
- **Proposed refinement:** Emit light selection tick every 5 seconds of scrubbed audio timeline.
- **Expected result:** Delightful analog scrubbing feedback.
- **Implementation location:** `lib/widgets/timeline_voice_player_pill.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Drag scrubber thumb across voice note waveform.

#### APPLE-145: Quick Tag Pill Multi-Selection Haptic
- **Reference:** Apple Notes tag selection: crisp tick on each tag tapped.
- **Our current implementation:** Silent chip selection.
- **Problem:** Lacked responsive confirmation in note composer.
- **Proposed refinement:** Fire selection click on each tag chip toggle.
- **Expected result:** Snappy, responsive tagging workflow.
- **Implementation location:** `lib/dialogs/note_dialog.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Tap tags in note composer.

#### APPLE-146: Vault Unlock Success Haptic
- **Reference:** Apple FaceID / Passcode unlock: subtle double-tick upon successful authentication.
- **Our current implementation:** Single click.
- **Problem:** Understated success sensation.
- **Proposed refinement:** Emit rapid double-tick haptic upon correct vault PIN entry.
- **Expected result:** Satisfying vault unlock confirmation.
- **Implementation location:** `lib/dialogs/vault_password_dialog.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Enter correct vault PIN.

#### APPLE-147: Haptic Setting Respect Invariant
- **Reference:** User preference: all haptics completely silenced when haptics disabled in settings.
- **Our current implementation:** Mostly respected, but raw `HapticFeedback.selectionClick()` bypassed preference in a few dialogs.
- **Problem:** Vibrations persisted even when user explicitly turned haptics off.
- **Proposed refinement:** Route all haptics through `NotekarHaptics` / `AppHaptics` which checks preference guard.
- **Expected result:** 100% silent operation when user requests silence.
- **Implementation location:** `lib/utils/app_utils.dart`, `lib/dialogs/app_sheet.dart`, `lib/widgets/toolbar.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Disable haptics in Settings; verify complete silence throughout app.

#### APPLE-148: Session Timer Start / Pause Tactile Feedback
- **Reference:** Apple Stopwatch: firm tactile click on start, muted click on pause.
- **Our current implementation:** Standard light click on both.
- **Problem:** Lacked mechanical stopwatch tactile response.
- **Proposed refinement:** Medium impact on start, light impact on pause.
- **Expected result:** Tangible, confident session controls.
- **Implementation location:** `lib/screens/note_kar_home.dart`, `lib/widgets/clock_face.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Start and pause focus session timer.

#### APPLE-149: Swipe Action Haptic Detent on Card Bed
- **Reference:** Apple Mail: distinct tick when swiping reaches action trigger distance.
- **Our current implementation:** Silent until delete button tapped.
- **Problem:** User couldn't feel when swipe reached trigger depth.
- **Proposed refinement:** Emit light impact when swipe reveals full action bed.
- **Expected result:** Tactile confirmation of swipe gesture.
- **Implementation location:** `lib/widgets/swipeable_card_bed.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Swipe timeline card left.

#### APPLE-150: Reorder Item Pick-Up & Drop Haptics
- **Reference:** Apple iOS drag & drop: firm pulse on pick-up, light click on drop.
- **Our current implementation:** Silent reordering in milestone lists.
- **Problem:** Lacked tactile weight during item reordering.
- **Proposed refinement:** Medium impact when item begins dragging, light click when settled into new slot.
- **Expected result:** Tangible physical reordering sensation.
- **Implementation location:** `lib/dialogs/projects_sheet.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Reorder milestones in Projects sheet.

---

### Section J: Dark Mode, Theming & Premium Finishing Details

#### APPLE-151: Pure OLED Black Canvas Contrast Refinement
- **Reference:** BitChord `DarkColors`: background `#000000`, surface `#0D0D0F`, surfaceVariant `#1C1C1E`.
- **Our current implementation:** Amoled theme used `#000000`, `#0A0A0C`, `#141416`, `#1E1E22`.
- **Problem:** Tonal steps between amoled surfaces were too compressed (`0x0A` to `0x14` is only 10 values), reducing card visibility.
- **Proposed refinement:** Calibrate amoled theme steps: `bg = #000000`, `surface = #0C0C0E`, `surface2 = #18181B`, `surface3 = #242428`.
- **Expected result:** Luminous, crystal-clear card contrast while maintaining pure black battery savings.
- **Implementation location:** `lib/models/palette.dart`.
- **Complexity:** Small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Inspect card edges on Amoled theme in a dark room.

#### APPLE-152: Light Mode Card Tonal Differentiation
- **Reference:** BitChord `LightColors`: background `#FFFFFF`, surface `#F7F7F9`, surfaceVariant `#F2F2F7`.
- **Our current implementation:** Light theme `surface` and `surface2` were both `#FFFFFF`.
- **Problem:** Card backgrounds were identical to modal sheet backgrounds, losing visual depth.
- **Proposed refinement:** Set light theme `bg = #F2F2F7`, `surface = #F7F7F9`, `surface2 = #FFFFFF` with soft 0.03 drop shadow.
- **Expected result:** Beautiful, natural card grouping in light mode.
- **Implementation location:** `lib/models/palette.dart`, `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect Settings and History in Light mode.

#### APPLE-153: Hairline Separator Contrast on Light Surfaces
- **Reference:** BitChord `outline = Color(0xFFE5E5EA)`.
- **Our current implementation:** Separator in light mode was `#E4E4E4` with variable alpha.
- **Problem:** Separators occasionally looked either invisible or too dark.
- **Proposed refinement:** Lock light mode hairline separators to `#E5E5EA` at full opacity.
- **Expected result:** Crisp, pixel-perfect Apple-grade row dividers.
- **Implementation location:** `lib/models/palette.dart`, `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Inspect list row dividers in Light mode.

#### APPLE-154: Accent Color Luminous On-Accent Text Optimization
- **Reference:** BitChord `glassContentColor`: dynamic luminance threshold.
- **Our current implementation:** `onAccent` used `accent.computeLuminance() > 0.45 ? Colors.black : Colors.white`.
- **Problem:** Worked well, but on Amber/Gold palettes edge cases could produce low contrast on small text.
- **Proposed refinement:** Enhance `onAccent` calculation with WCAG 2.1 relative luminance algorithm for guaranteed 4.5:1 ratio.
- **Expected result:** 100% compliant contrast on all accent buttons across Amber, Gold, Lime, and Blue.
- **Implementation location:** `lib/models/palette.dart`.
- **Complexity:** Very small.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** Test Amber and Lime accents with white vs black label text.

#### APPLE-155: Matrix Theme Monospace & Retro Restraint
- **Reference:** NoteKar Matrix theme identity: sovereign terminal aesthetic.
- **Our current implementation:** Matrix theme green borders were occasionally overwhelming (`0.8` alpha).
- **Problem:** Visual fatigue from high-saturation neon borders.
- **Proposed refinement:** Restrain Matrix theme border alpha to `0.35` for cards, keeping neon `0xFF00FF41` for active data highlights.
- **Expected result:** Sophisticated Cyberpunk aesthetic that remains comfortable for long reading sessions.
- **Implementation location:** `lib/models/palette.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect Matrix theme in dark room.

#### APPLE-156: E-Ink Theme Zero-Shadow & Pure Hairline Invariant
- **Reference:** E-Ink display physics: electronic paper cannot render gradients, blurs, or shadows.
- **Our current implementation:** E-ink theme set colors to black and white, but `Glass` still rendered box shadows.
- **Problem:** Ghosting and muddy blotches on E-Ink readers (Boox, Kindle).
- **Proposed refinement:** When `theme == 'eink'`, completely strip all shadows, blurs, and gradients; render 1.0px solid black borders.
- **Expected result:** Flawless, crisp e-paper rendering with zero ghosting.
- **Implementation location:** `lib/widgets/glass.dart`, `lib/widgets/design_system/nk_card.dart`.
- **Complexity:** Small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Switch to E-Ink theme and verify crisp, flat black-on-white surfaces.

#### APPLE-157: Theme Transition Cross-Fade Polish
- **Reference:** Apple iOS appearance toggle: smooth animated color transition across entire window.
- **Our current implementation:** Theme switch swapped colors instantly with brief flash.
- **Problem:** Jarring flash when toggling dark mode in Settings.
- **Proposed refinement:** Animate theme change with 220ms smooth cross-fade via `ThemeData` lerp.
- **Expected result:** Gentle, seamless transition between dark and light modes.
- **Implementation location:** `lib/main.dart`, `lib/models/palette.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Toggle Dark/Light mode in Display settings.

#### APPLE-158: Status Bar Clock AM/PM Display Precision
- **Reference:** Apple Status Bar: clean AM/PM or 24h format aligned with system locale.
- **Our current implementation:** AM/PM string was hardcoded to `''` when `use24HourFormat` was false in clock face.
- **Problem:** Users in 12-hour mode lacked AM/PM clarity.
- **Proposed refinement:** Correctly compute and display localized AM/PM indicator in 12-hour mode.
- **Expected result:** Complete, accurate time indication.
- **Implementation location:** `lib/widgets/clock_face.dart`.
- **Complexity:** Very small.
- **Priority:** High.
- **Risk:** None.
- **Verification:** Switch to 12-hour mode and inspect clock face.

#### APPLE-159: Remove Unnecessary Visual Separators
- **Reference:** Apple HIG: whitespace and typography distinguish sections; avoid redundant dividers.
- **Our current implementation:** Several sub-sheets had dividers between title and content AND around cards.
- **Problem:** Visual noise and fragmented vertical scanning.
- **Proposed refinement:** Remove redundant full-width dividers; rely on card boundaries and 16pt whitespace.
- **Expected result:** Calm, uncluttered layout.
- **Implementation location:** `lib/dialogs/settings/app_permissions_settings_page.dart`, `lib/dialogs/settings/content_rating_settings_page.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Review permissions and content rating settings pages.

#### APPLE-160: Icon Alignment Precision in Multi-Line Rows
- **Reference:** Apple HIG Table View: leading icon is top-aligned with title on multi-line rows, centered on single-line rows.
- **Our current implementation:** In `SettingsSwitchRow`, icon was centered on total row height, leaving it awkwardly low on 2-line subtitles.
- **Problem:** Leading icon looked detached from the title it represented.
- **Proposed refinement:** Top-align leading icon with `margin: EdgeInsets.only(top: 2.0)` on rows with subtitles.
- **Expected result:** Perfect alignment between leading icon and title text.
- **Implementation location:** `lib/widgets/settings_widgets.dart`, `lib/widgets/design_system/nk_list_tile.dart`.
- **Complexity:** Very small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Inspect settings rows with long 2-line subtitles.

#### APPLE-161: Clock Complication Sub-Dial Proportions
- **Reference:** Apple Watch Hermès / Infograph complications: crisp hairline circular sub-dials.
- **Our current implementation:** Complication circle had thick border.
- **Problem:** Competed with main clock hands.
- **Proposed refinement:** Refine complication border to 0.5 hairline with 11pt tabular numerals.
- **Expected result:** Precision chronometer complication.
- **Implementation location:** `lib/widgets/home_clock_complication.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Inspect clock complication on home screen.

#### APPLE-162: History Calendar Grid Day Cell Touch Comfort
- **Reference:** Apple Calendar month view: generous circular touch target with active dot indicator.
- **Our current implementation:** Day cells had tight touch bounding boxes.
- **Problem:** Difficult to tap specific days on small screens.
- **Proposed refinement:** Ensure each calendar day cell has minimum 44x44 touch hit box.
- **Expected result:** Effortless date navigation in History calendar.
- **Implementation location:** `lib/widgets/history_calendar_view.dart`.
- **Complexity:** Small.
- **Priority:** Medium.
- **Risk:** None.
- **Verification:** Tap individual days in History calendar grid.

#### APPLE-163: Diagnostic Logs Monospace Readability
- **Reference:** Apple Console / Xcode logs: clean JetBrains/SF Mono, 12pt, alternating row tints.
- **Our current implementation:** Raw unformatted text dump.
- **Problem:** Hard to isolate specific log events or errors.
- **Proposed refinement:** Format diagnostic logs in tabular monospace rows with colored severity chips (INFO, WARN, ERR).
- **Expected result:** Beautiful, professional developer diagnostics view.
- **Implementation location:** `lib/dialogs/settings/diagnostics_settings_page.dart`.
- **Complexity:** Small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open Diagnostics in Settings.

#### APPLE-164: Adaptive Monochrome App Icon Integration (Android 13+)
- **Reference:** Modern Android 13/14/15: themed monochrome icon adapts to user's Material You wallpaper tint.
- **Our current implementation:** Implemented in Android manifest, but icon switcher had slight preview mismatch.
- **Problem:** Preview in settings didn't match system icon rendering.
- **Proposed refinement:** Align settings icon preview with actual Android adaptive monochrome vector.
- **Expected result:** Accurate preview of themed icon styles.
- **Implementation location:** `lib/dialogs/settings/app_icons_settings_page.dart`.
- **Complexity:** Very small.
- **Priority:** Low.
- **Risk:** None.
- **Verification:** Open App Icons settings page.

#### APPLE-165: Global Visual Polish & Regression Lock
- **Reference:** Apple Gold Master quality standards: zero visual regressions, zero compilation warnings, 100% passing tests.
- **Our current implementation:** Ensure all 483+ existing tests stay passing and `flutter analyze` reports 0 issues.
- **Problem:** Any regression threatens the sovereign reliability of the application.
- **Proposed refinement:** Run complete automated test suite and static analysis after every batch.
- **Expected result:** Rock-solid stability, zero regressions, exceptionally polished release.
- **Implementation location:** Entire codebase (`lib/`, `test/`).
- **Complexity:** Medium.
- **Priority:** Critical.
- **Risk:** None.
- **Verification:** `flutter analyze` -> 0 issues; `flutter test` -> 483+ passed.

---

## 6. Implementation Architecture & Execution Sequence

Implementation proceeds in 8 logically isolated, verifiable batches:
1. **Batch 1: Core Tokens, Curvature & Typography Scale** (`app_tokens.dart`, `palette.dart`, `main.dart`).
2. **Batch 2: Switch & Toggle Unification** (`nk_ios_switch.dart`, `nk_list_tile.dart`, `settings_widgets.dart`, `hig_widgets.dart`).
3. **Batch 3: Sliding Pill Segmented Controls** (`nk_pill_segmented_control.dart`, `settings_widgets.dart`, `goals_sheet.dart`).
4. **Batch 4: Inset Grouped Cards & List Tiles** (`nk_card.dart`, `nk_list_tile.dart`, `settings_widgets.dart`, `hig_widgets.dart`).
5. **Batch 5: Glass Restraint & Floating Chrome** (`glass.dart`, `toolbar.dart`, `top_fade_blur.dart`).
6. **Batch 6: Button Shape Flexibility & Pressable Feedback** (`nk_button.dart`, `pressable_scale.dart`).
7. **Batch 7: Modal Sheets & Touch Targets** (`app_sheet.dart`, `app_tokens.dart`).
8. **Batch 8: Timeline, Checkpoints & Detail Finishing Details** (`timeline_single_tile.dart`, `checkpoints_quick_bar.dart`, `digital_wellbeing_card.dart`).
