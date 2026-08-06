---
description: Review uncommitted changes for bugs, security, structure, and public-safety. Routes to the maximum-reasoning agent (Kimi K3) for a thorough review. For special-purpose reviews, not general work.
agent: security-reviewer
---

Review the current uncommitted changes (git diff) for bugs, security, and structure.

Scope: $ARGUMENTS

1. `git status --short` and `git diff` (staged + unstaged). Also check `git diff origin/main..HEAD` if recently committed.
2. Review for: security issues (secrets, exposure, sops hygiene), NixOS correctness against pinned 26.05, structure/consistency with OpenCode.md, and public-safety of the repo.
3. Report findings as a numbered list with severity, file:line where possible, and a concrete fix.
