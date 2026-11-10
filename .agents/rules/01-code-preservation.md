---
description: Mandatory code preservation standard preventing accidental deletion, stubbing, or clobbering of working code
globs: **/*.dart, **/*.kt, **/*.kts, **/*.xml
---

# 01 - Code Preservation & Zero-Destruction Standard

## 1. Prime Directive
**Existing working code is valuable, tested, and battle-hardened. You must never remove, stub out, comment out, or silently replace working functionality.**

## 2. Forbidden Actions
1. **Never Replace Working Implementations with Placeholders**:
   - Strictly forbidden: `// TODO: Implement later`, `throw UnimplementedError()`, or omitting existing method bodies.
   - Never replace complex algorithms or state machines with simplified approximations.
2. **Never Delete or Comment Out Tests**:
   - If an existing test fails after a change, the change is broken or violated an existing contract. Fix the change—do not delete, comment out, or disable the failing test.
3. **Never Remove Unrelated Features During Bug Fixes**:
   - When fixing a bug in a file (e.g., `note_kar_home.dart`), do not modify, remove, or "clean up" adjacent methods, comments, or data structures.
4. **Never Truncate Large Files**:
   - Many of NoteKar's core screens and widgets are intentionally rich and comprehensive. When editing, perform precise target replacements; never rewrite entire files from scratch.

## 3. Mandatory Verification Checklist
Before completing any edit:
- [ ] Has every pre-existing function signature remained intact?
- [ ] Are all existing public and private helper methods preserved?
- [ ] Have all pre-existing comments and documentation blocks been retained?
- [ ] Does `git diff` show only changes directly required for the requested task?
