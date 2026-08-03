---
description: Stage and commit the current changes with a descriptive message per the repo's conventions.
agent: nixos-builder
---

Commit the current working-tree changes.

Message hint / scope: $ARGUMENTS

1. Inspect `git status` and `git diff` first. Stage only intended files — never secrets or Memory.md.
2. Write a concise, descriptive commit message that matches the repo style (imperative, ~50 chars subject).
3. Commit. Do not push unless asked.
