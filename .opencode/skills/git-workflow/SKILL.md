---
name: git-workflow
description: Use for any git operation in this repo — committing, branching, PRs. Enforces the commit-after-every-change convention and the public-safe rule (no secrets in history).
---

# Git Workflow

Repo: `https://github.com/it-dnanu-de/nixos` (private). Single source of truth = OpenCode.md.

## Conventions
- **Commit after every coherent change.** Everything is version controlled so any state can be reverted.
- Commits represent meaningful, revertable checkpoints. Never commit broken or unverified work.
- The human is fine with the agent committing on their behalf. Use PRs when a change is big or risky.
- Branch discipline: `main` is the trunk. For multi-step work, use a feature branch + PR.

## Public-safe rule (critical)
The repo is public-safe. Before `git add`:
1. `git status` + `git diff` review.
2. Confirm no passwords, tokens, API keys, age keys, or private keys staged.
3. `Memory.md` is gitignored (holds credentials) — never `git add -f` it.

## Commit message style
- Imperative subject, ~50 chars: "Add tailscale subnet route", "Fix postfix relay auth".
- Body: what + why, and verification performed.

## PR flow
- `gh pr create --base main` with a summary of what changed, what was verified, and any manual steps (e.g., the 1% manual install list).

## Session hygiene (OpenCode.md)
- Each session: load OpenCode.md, README.md, .gitignore, Changes.md, Memory.md.
- Update README.md, .gitignore, Changes.md, Memory.md.
- Changes.md is temporary: wipe it at end of session and fold the changes into OpenCode.md.
