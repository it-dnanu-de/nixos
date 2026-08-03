---
description: Start a full working session. Loads context, probes the environment, asks the human setup questions, routes work to the right model tier, and drives the build order. Run this once per session.
---

# Init

You are the session orchestrator. You are the primary agent; delegate heavy or specialized work to the tiered subagents (architect / nixos-builder / verifier / security-reviewer / deployer) via the `task` tool. Route by task, not by mood:

| Task | Route to |
|---|---|
| Planning, architecture, breaking down milestones, hard debugging | `architect` (T3, Kimi K3) |
| Writing NixOS modules / flake / service config | `nixos-builder` (T2, DeepSeek V4 Pro) |
| Verifying an option/package exists in pinned 26.05 | `verifier` (T1, DeepSeek V4 Flash) |
| Security audit: DNSSEC, TLS, firewall, sops hygiene | `security-reviewer` (T3, Kimi K3) |
| Rebuilding/deploying on 10.0.0.2 | `deployer` (T2, DeepSeek V4 Pro) |

## Step 0 — Context
The instructions already inject OpenCode.md, README.md, Changes.md, Memory.md, .gitignore. Treat OpenCode.md as the single source of truth. If anything is marked ✅ LOCKED, do not revisit it. ⚠️ VERIFY flags get checked before use.

## Step 1 — Probe the environment (report, don't guess)
Run these and note the results in your reply:
- `git status --short` and `git log --oneline -5` — what state is the repo in?
- `git rev-parse --abbrev-ref HEAD` and check for unpushed commits (`git log origin/main..HEAD --oneline`).
- Toolchain: `command -v node npm gh nix sshpass` — note which exist.
- Server: is 10.0.0.2 reachable? `ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@10.0.0.2 true && echo REACHABLE || echo UNREACHABLE`. Report the result — do not claim reachability without checking.
- MCP servers: `opencode mcp list` — note which are connected/failed. `ssh-homelab` failing usually means `HOMELAB_SSH_PASSWORD` is not exported in the shell that launched opencode.
- Working tree contains any uncommitted WIP? If so, fold it into the session instead of losing it.

## Step 2 — Ask the human (use the `question` tool)
Ask in ONE batch, at most 4-5 questions, then proceed. Do not re-ask what is already answered in Memory.md.
1. Is the NixOS live ISO booted on the Dell and reachable at 10.0.0.2 right now? (No / yes, sshd running / not sure)
2. Which milestone do you want this session to drive? (Default: verify the pinned channel table, then start build order step 1 — flake + settings + sops skeleton.)
3. Are the credentials/secrets ready (age key on USB/password manager, Cloudflare token, Resend key)? (Not yet — use placeholders / yes / partial)
4. Anything new for Memory.md (server IP, passwords, tokens)? Confirm before storing — never echo secrets in chat verbatim unless already known.

## Step 3 — Record session state
- Update Memory.md (gitignored) with any new operational facts. Never commit it.
- Append to Changes.md (tracked) a dated entry for this session start.
- If the answer to Q1 is "reachable", ask `deployer` to run a live-ISO smoke test (sshd, disk, memory) so later installs have a baseline.

## Step 4 — Default first milestone (until the human overrides)
1. Route the ⚠️ VERIFY sweep to `verifier` against the pinned `nixos-26.05` reference: every service module in §9, SNM `accounts`/`sieveScript`/`recipientDelimiter`/`x509`, Booklore, Collabora, and the packages (hugo, beets, intel-vaapi/media-driver). Collect results as the verification table.
2. Present the table to the human and PAUSE for approval before writing any other code. The prompt in OpenCode.md is explicit: no other code until the table is approved.
3. After approval, build order step 1 only: `flake.nix` + `settings.nix` + sops skeleton (`secrets/`, `.sops.yaml`). Use `architect` to confirm the flake input list, then `nixos-builder` to write it, `verifier` to re-check each referenced option, `security-reviewer` to sanity-check the sops skeleton. Commit after each coherent milestone.

## Step 5 — Session hygiene (required every session)
- At the end, wipe Changes.md into OpenCode.md (fold durable decisions in, then truncate Changes.md).
- Update README.md and .gitignore if the project's shape changed.
- Commit. Push only if the human asked or it's the end of a milestone.
