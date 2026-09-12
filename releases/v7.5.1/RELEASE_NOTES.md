## 🌟 NoteKar v7.5.1 (`26BR0912`)

> *"Elegance is when the inside is as beautiful as the outside."* This release brings absolute
> harmony to NoteKar: universal Light, Dark, and AMOLED themes across every sheet and dialog,
> dedicated Mode workspaces, rich Android Home Screen widgets, tactile depleting undo progress, and
> silky 120Hz motion decoupling.

---

### What's New

#### 🎨 Universal Light, Dark & AMOLED Harmony

- **Deep Theme Parity**: Every popup, Apple-style Cupertino action sheet, alert dialog, date/time
  picker, and text input now dynamically resolves to the user's active theme.
- **AMOLED True Pitch Black**: Contrast-perfect pure `#000000` dark surfaces with razor-sharp
  borders and zero light bleed.
- **Adaptive Toast & Notice Pills**: Fluid translucent white surfaces in Light mode, elevated dark
  sheets in Dark mode, and pitch-black tactile capsules in AMOLED mode.

#### 🧭 Dedicated Modes & Category Workspaces

- **Dedicated Mode Pages**: Selecting any logging mode transitions smoothly into its own dedicated
  settings page with native back chevron and gesture pop.
- **Ergonomic 15-Character Limit**: Enforces concise, legible mode titles across home pills, session
  cards, and notifications.
- **Protected Mode Lifecycle**: Safe deletion workflow featuring an Apple-grade destructive
  confirmation dialog relocated to the bottom of individual mode pages.
- **Persistent Selection**: Active mode stays synchronized across cold boots and app updates with
  zero-friction 1-tap logging.

#### 📱 Dedicated Android Home Widgets & Dynamic Notification

- **3 Dedicated Home Screen Widgets**: Quick Capture & Active Mode, Sobriety & Habit Companion, and
  Life Audit Conscious Balance meters with native launcher preview drawables.
- **Dynamic Persistent Notification**: Displays real-time session state (`🟢 IN • <Category>` or
  `⚪ Ready`), elapsed check-in time, and daily moment counts with quick-action toggles.

#### ⚡ 120Hz Fluid Motion & Ergonomic Safety Zone

- **Decoupled Accelerometer Engine**: Motion listeners are isolated strictly to animated chronometer
  glyphs using `RepaintBoundary`, eliminating root rebuilds for stutter-free 120Hz scrolling.
- **Ghost Tap Prevention**: Ergonomic bounding box deadens status bar, top insights, and bottom
  navigation toolbar, preventing accidental touches while maintaining full edge-to-edge
  reachability.
- **Jitter-Free Navigation**: Seamless transition from History sheet to Search Notes without modal
  barrier stutter or frame drops.

#### 🔍 80/20 Search Notes & #Hashtag Filters

- **80/20 Content Hero Layout**: 80% dominant note content paired with 20% contextual metadata
  capsules (`SINGLE` vs `2-WAY` mode badges, in/out timestamps, and elapsed duration).
- **Dynamic #Hashtag Pill Bar**: Automatically parses hashtags from notes into a horizontal
  Apple-grade filter bar for one-tap tag isolation.
- **Depleting Animated Undo Pill**: 3500ms smooth depleting accent progress bar with instant
  single-tap restoration for edited or added notes.

---

### Integrity

- **Build Tag**: `26BR0912` (version `7.5.1+26091201`)
- **Automated Tests**: 136 unit & widget tests passing (0 failures, 0 lints)
