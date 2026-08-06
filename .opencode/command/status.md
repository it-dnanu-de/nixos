---
description: Report the state of the repo, the homelab server, and the toolchain in one go. Routed to V4 Flash (planner-low) as a lightweight info-gathering task.
agent: planner-low
---

Give a concise status report covering:

1. Git: current branch, `git status --short`, unpushed commits, last commit.
2. Server: is 10.0.0.2 reachable? ssh-connectivity check (ssh may prompt — prefer a non-interactive check like `ssh -o BatchMode=yes -o ConnectTimeout=5 root@10.0.0.2 true` and report the result).
3. Toolchain: is `node`/`npx` present (needed by the npx-based MCP servers)? Is `gh` authenticated?
4. Any open issues in the repo (gh issue list).

$ARGUMENTS
