---
name: test-regression
description: Execute comprehensive multi-tier regression testing across all 73+ NoteKar test suites, models, and lifecycles.
---

# Regression Testing Gauntlet

Execute the regression testing workflow for NoteKar:

1. Follow all steps in [.agents/workflows/05-regression-testing.md](file:///.agents/workflows/05-regression-testing.md).
2. Tier 1: Run fast smoke tests (< 30s): `accent_palette_test.dart`, `widget_test.dart`, etc.
3. Tier 2: Run timeline and session lifecycle suites (`life_ledger_timeline_test.dart`, etc.).
4. Tier 3: Run Apple HIG component token suites.
5. Tier 4: Run security, storage, and migration suites (`vault_encryption_service_test.dart`, etc.).
6. Tier 5: Run full repository test suite: `flutter test`.
7. Verify 100% pass rate.
