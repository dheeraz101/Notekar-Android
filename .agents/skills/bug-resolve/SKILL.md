---
name: bug-resolve
description: Diagnose, isolate, reproduce with an automated test, and surgically patch a bug in NoteKar with zero side-effects.
---

# Bug Investigation & Resolution

Execute the bug investigation and resolution workflow for NoteKar:

1. Follow all steps in [.agents/workflows/04-bug-investigation-resolution.md](file:///.agents/workflows/04-bug-investigation-resolution.md).
2. Step 1: Trace execution path, logs, and check against domain invariants (`.agents/rules/11-notekar-domain-invariants.md`).
3. Step 2: Write an automated reproducing test in `test/` and verify it fails.
4. Step 3: Apply minimal surgical patch (< 50 lines) to the root cause.
5. Step 4: Verify the reproducing test passes, then run full verification (`.\scripts\verify.ps1`).
