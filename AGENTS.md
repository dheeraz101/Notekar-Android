# NoteKar AI Engineering Directive & Operational Standard

> **Core Mandate**: Every AI agent operating on NoteKar must work with the discipline, precision, and predictability of a senior software engineering team.
> 
> **Standard Operating Lifecycle**:
> **Inspect → Understand → Plan → Approve → Implement → Build → Test → Visually Verify → Review → Commit**

---

## 1. Prime Directives (Non-Negotiable)

1. **Code Preservation Over Code Generation**:
   - Never remove, stub out, comment out, or truncate existing working code, tests, or models.
   - Any modification must be strictly surgical, additive, or isolated.
   - Do not perform unsolicited refactorings, architectural restructuring, or cosmetic reformatting of untouched code.

2. **Apple HIG Elegance × Android Native Authenticity**:
   - Maintain the established aesthetic: Apple Human Interface Guidelines spatial harmony, continuous superellipse squircles (`28pt` sheets/dialogs, `16pt` cards), SF/Inter typography with negative tracking, and tabular figures for numbers.
   - Respect Android native platform conventions: Material 3 zoom transitions, edge-to-edge layout, predictive back gestures, monochrome status notifications (`ic_stat_notekar`), Dynamic Broadcast Receivers (`Context.RECEIVER_EXPORTED` on API 33+), and RemoteViews widget background sync.

3. **Zero Telemetry & 100% Air-Gapped Privacy**:
   - NoteKar is strictly offline-first. Never introduce network telemetry, analytics pings, remote crash reporters, or third-party cloud SDKs.
   - All encrypted `.notekar-vault` exports must adhere to PBKDF2-SHA256 (>= 100,000 iterations) and AES-256-GCM authenticated encryption.

4. **Zero-Lint & Zero-Regression Verification Gate**:
   - Before completing any turn or proposing a commit:
     1. Static analysis MUST pass with zero warnings and zero errors: `flutter analyze --fatal-infos --fatal-warnings`.
     2. Automated tests MUST pass with 100% success rate: `flutter test`.
     3. Code formatting must be clean: `dart format --output=none --set-exit-if-changed lib/ test/`.
   - Never bypass or disable pre-commit or pre-push Git hooks.

5. **Visual Quality Assurance**:
   - Any modification touching UI components, layouts, dialogs, or themes must be visually verified across **Light**, **Dark**, and **AMOLED** themes.
   - Ensure touch targets strictly meet or exceed the accessibility minimum: **48×48dp** (`NkTouchTarget.minInteractive`).

---

## 2. Rule Hierarchy & Progressive Discovery

Antigravity automatically discovers and loads rules located in `.agents/rules/`. Every agent must comply with all rule modules:

- [01-code-preservation.md](file:///.agents/rules/01-code-preservation.md): Strict rules against deleting working code or clobbering existing implementations.
- [02-minimal-isolated-change.md](file:///.agents/rules/02-minimal-isolated-change.md): Surgical edits, single-responsibility diffs, and change containment.
- [03-apple-hig-ui-consistency.md](file:///.agents/rules/03-apple-hig-ui-consistency.md): Squircle geometry, typography scale, semantic tokens, and pressable scale motion.
- [04-android-native-behavior.md](file:///.agents/rules/04-android-native-behavior.md): Predictive back, RemoteViews widget sync, dynamic receivers (API 26–35), and tiles.
- [05-security-privacy.md](file:///.agents/rules/05-security-privacy.md): Zero network calls, PBKDF2/AES-GCM encryption, biometric auth, and sandbox storage.
- [06-error-handling-resilience.md](file:///.agents/rules/06-error-handling-resilience.md): Safe null-guards, ByteData buffer slicing, migration bridges, and defensive error boundaries.
- [07-performance-efficiency.md](file:///.agents/rules/07-performance-efficiency.md): 60/120fps frame rendering budget, repaints, debouncing, and memory leak prevention.
- [08-accessibility.md](file:///.agents/rules/08-accessibility.md): TalkBack labels, semantic roles, high contrast, and dynamic text scaling.
- [09-testing-verification.md](file:///.agents/rules/09-testing-verification.md): Mandatory test suites, Isar in-memory testing, and CI parity checks.
- [10-dependency-management.md](file:///.agents/rules/10-dependency-management.md): Strict zero-unnecessary-dependency policy and version locking.
- [11-notekar-domain-invariants.md](file:///.agents/rules/11-notekar-domain-invariants.md): Hard-won domain invariants (SharedPreferences set types, timeline gap pairing, and session lifecycle).

---

## 3. Reusable Workflows & Slash Commands

When assigned a development task, use the appropriate standardized workflow from `.agents/workflows/`:

| Command | Workflow | Description |
| :--- | :--- | :--- |
| `/app-audit` | Complete Application Audit | Audits architecture, dependencies, test suite health, lint, and build sanity. |
| `/safe-feature` | Safe Feature Implementation | Staged 6-phase implementation lifecycle ensuring zero regressions. |
| `/hig-review` | UI/UX & Apple HIG Review | In-depth audit of visual tokens, typography, squircles, contrast, and haptics. |
| `/bug-resolve` | Bug Investigation & Resolution | Root-cause isolation, test-driven reproduction, and surgical patching. |
| `/test-regression`| Regression Testing Gauntlet | Complete test suite execution across all 73 test suites and Isar migrations. |
| `/perf-analyze` | Performance & Battery Analysis | Frame pacing, widget rebuild profiling, memory allocations, and wake locks. |
| `/security-audit` | Security & Air-Gap Audit | Verification of zero network traffic, vault cryptographic integrity, and IPC safety. |
| `/release-ready` | Release-Readiness Verification | Pre-flight release gauntlet, multi-ABI verification, Proguard mapping, and SHA-256. |

---

## 4. Git Safety Strategy

- Always create a temporary checkpoint before complex edits: `git checkout -b checkpoint/<task>-<timestamp>`.
- Never run destructive Git commands (`git reset --hard`, `git clean -fd`, `git checkout .`) without explicit user permission.
- Always run `.\scripts\verify.ps1` before committing or pushing.
