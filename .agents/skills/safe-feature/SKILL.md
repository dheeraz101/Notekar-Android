---
name: safe-feature
description: Guide and execute safe, non-destructive, test-verified feature implementation on NoteKar with zero regressions.
---

# Safe Feature Implementation

Execute the safe feature implementation workflow for NoteKar:

1. Follow all phases in [.agents/workflows/02-safe-feature-implementation.md](file:///.agents/workflows/02-safe-feature-implementation.md).
2. Phase 1: Inspect target domain, scope, and tokens.
3. Phase 2: Create a safety checkpoint branch (`git checkout -b feat/<name>`).
4. Phase 3: Implement domain models and services with backwards-compatible migrations.
5. Phase 4: Implement Apple HIG UI using `NkTokens`, `NkCard`, and squircle curvature.
6. Phase 5: Write automated tests in `test/` verifying the new feature.
7. Phase 6: Run full verification gate via `.\scripts\verify.ps1`.
