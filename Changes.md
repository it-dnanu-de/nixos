# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

## 2026-08-03 — opencode workflow: model routing + Init command
- Wired T1/T2/T3 models into all 5 agents: architect + security-reviewer -> `openrouter/moonshotai/kimi-k3` (T3), nixos-builder + deployer -> `openrouter/deepseek/deepseek-v4-pro` (T2), verifier -> `openrouter/deepseek/deepseek-v4-flash` (T1).
- Created `.opencode/command/init.md`: the session orchestration entry point. Probes env, asks the human setup questions, routes to tiered subagents, drives the frozen build order, pauses for approval before writing code.
- Fixed `opencode.json` references: `snm` -> GitLab URL (it's not on GitHub), `disko` -> `nix-community/disko`. Deleted the manual reference clones (reverted); opencode re-materializes them on use.
- Updated `mail-stack` skill with verified SNM renames (`loginAccounts` -> `accounts`, `certificateScheme` removed -> `x509.{useACMEHost,certificateFile,privateKeyFile}`; `sieveScript` + `recipientDelimiter` exist).
- Added model-routing + Init guidance to `nixos-flake` skill.
- README: documented the `/init` workflow and the agent->model routing table.

## 2026-08-03 — opencode tooling bootstrap
- Created `opencode.json`: instructions (OpenCode.md/README/Changes/Memory/.gitignore), MCP servers (context7, github, ssh-homelab, playwright), references (nixpkgs@s26.05, snm, disko, sops-nix, nixos-anywhere, vpn-confinement), permissions (bash allow, ~/secrets deny), experimental mcp_timeout 30s, compaction tail 15.
- Created agents: architect (T3), nixos-builder (T2, primary), verifier, security-reviewer, deployer.
- Created commands: deploy, rebuild, verify, update, secrets, commit, pr, status.
- Created skills: nixos-flake, sops-secrets, mail-stack, zfs-disko, deployment, verification, security-hardening, git-workflow.
- .gitignore: ignored Memory.md (was tracked), .env, *.age, node_modules; untracked Memory.md.
- Memory.md populated with server creds + MCP notes.
- Verified MCP packages: context7 remote (no auth), GitHub managed endpoint (OAuth), `@fangjunjie/ssh-mcp-server`, `@playwright/mcp@latest`. Confirmed `gh mcp` unavailable in gh 2.97 and `@kevinwatt/ssh-mcp` does not exist.
- Pending: install node/npm (`sudo pacman -S nodejs npm`), then `opencode mcp auth github`, `npx playwright install chromium`.

## 2026-08-03 (follow-up) — MCP wiring fixes
- node v26.5.1 installed; `opencode mcp list` diagnostics run.
- `github` MCP DISABLED: `https://api.githubcopilot.com/mcp/` rejects opencode OAuth ("does not support dynamic client registration"). Use `gh` CLI instead.
- `ssh-homelab` fixed: `@fangjunjie/ssh-mcp-server` requires password at startup. Password now via `{env:HOMELAB_SSH_PASSWORD}` interpolation (verified working). User must `export HOMELAB_SSH_PASSWORD='123'` in the shell before launching opencode.
- Confirmed context7 + playwright connect. ssh-homelab connects when the env var is set.
