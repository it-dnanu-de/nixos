---
description: Create or update a pull request against it-dnanu-de/nixos.
agent: nixos-builder
---

Create a pull request for the current branch.

PR title / body hint: $ARGUMENTS

1. Inspect status, diff, and the base branch (`main`).
2. Use `gh` to create the PR: `gh pr create --base main --title "<title>" --body "<summary>"`.
3. Include what changed, what was verified, and any manual steps (e.g., the 1% manual install list).
4. Report the PR URL.
