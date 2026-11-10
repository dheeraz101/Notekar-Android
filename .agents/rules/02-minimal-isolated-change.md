---
description: Standard for minimal, isolated, and surgical code changes with zero side effects
globs: **/*.dart, **/*.kt, **/*.kts, **/*.xml
---

# 02 - Minimal & Isolated Modifications Standard

## 1. Scope Discipline
Every change introduced by an AI agent must have the smallest possible blast radius:
- Modify only the exact lines necessary to accomplish the user's objective.
- Do not refactor surrounding architecture unless explicitly commanded by the user.
- Do not reformat untouched code blocks or alter formatting styles across entire files.

## 2. Surgical Editing Rules
1. **Targeted Edits Only**:
   - Use surgical search-and-replace edits rather than complete file rewrites.
   - Ensure replacement blocks match existing indentation, naming conventions, and lint preferences.
2. **Single Responsibility per Change**:
   - Separate bug fixes from feature additions.
   - Never mix cosmetic refactoring with functional logic modifications in the same diff.
3. **Preserve Existing Interfaces & Contracts**:
   - Do not alter function arguments, return types, or default values on public APIs unless required for the feature.
   - Maintain backwards compatibility with existing preferences, database models, and native MethodChannel messages.

## 3. Git Diff Self-Audit
Before proposing or committing changes:
```powershell
git diff --stat
```
Verify that every touched file is directly relevant to the prompt. If any file was touched inadvertently, revert it immediately:
```powershell
git checkout -- <unrelated-file>
```
