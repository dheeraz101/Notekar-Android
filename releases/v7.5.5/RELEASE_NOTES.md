# NoteKar v7.5.5

> *Dynamic Momentum, Digital Wellbeing & Data Resilience*

Signed release - built automatically from the branch.

### What's New

- **Dynamic Momentum Capsule**:
  - Re-architected the resting home screen canvas for pure, distraction-free minimalism by moving Today's Momentum into the top `DynamicHeaderCapsule`.
  - Tapping the resting pill smoothly expands an Apple-grade card revealing live tracked duration, conscious moment count, streak flame, banked grace shields, active session status, and 1-tap navigation into the Executive Intelligence Hub.
- **Android Digital Wellbeing & Smart Buckets**:
  - Native offline integration with Android `UsageStatsManager` (`PACKAGE_USAGE_STATS`) using a 100% private, zero-telemetry architecture.
  - Automatic Smart Buckets categorization (Productivity, Social, Entertainment, System) via Android native `ApplicationInfo.category`.
  - Opt-in **Intentionality Reality Delta** dashboard in the Executive Intelligence Hub contrasting conscious intentional focus with raw device screen time.
- **Flagship Apple HIG Goals Engine & Sensory Architecture**:
  - Rebuilt goals system featuring pacing indicators, Cupertino segmented controls, and 1-tap session launching.
  - WhatsApp-style dark mode doodle wallpaper splash screen with authentic NoteKar center badge and instant dismiss.
  - Acoustic swipe-to-delete sound effect, refined bottom note composer, and independent goals navigation.
  - Implemented 4 strategic retention pillars: lock screen awareness, ambient pulse, and deficit targets.
- **Core Data Safety & Crash Protection**:
  - Automated corrupted-box snapshots: Hive database corruption now creates emergency timestamped local backups before recovery, eliminating silent data loss.
  - Restored streak grace-day logic: relapses no longer permanently lock out earned shields; grace days reset cleanly for new streaks.

### Improvements & Refinements

- **Platform Security & Receiver Hardening**:
  - Secured exported Android broadcast receivers with signature-level permissions (`android:protectionLevel="signature"`), preventing unauthorized intent spoofing.
- **Analytics Precision**:
  - Purged fabricated 15-minute durations assigned to single taps; true cross-boundary sessions and gap intervals are faithfully recorded.
  - Fixed 12:00 PM noon time formatting bug in risk radar (previously displayed as "12 AM").
- **Architectural God-Class Deconstruction**:
  - Extracted 3,100+ lines from monolithic settings dialog and modularized home screen lifecycle delegates.
  - Introduced systematic `NkTokens` design tokens for unified radii, typography, spacing, and elevation.

---

### Integrity

- **Build Tag**: `26BR0927` (version `7.5.5+26092701`)
- **Automated Tests**: All 234 unit, widget, and integration tests passing (0 failures, 0 lints)
- **Privacy Standard**: 100% offline, zero trackers, sandboxed local storage
