# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

## 2026-08-03 — build step 1 complete: flake + settings + sops skeleton + verified OpenCode

### Toolchain
- nix 2.35.1, sops 3.13.3, age 1.3.1 all installed locally (single-user nix, no daemon).
- nixpkgs reference clone restored from a broken worktree state.

### Verification sweep (all 43 items checked against pinned nixos-26.05)
| Category | ✅ | ⚠️ RENAMED | ❌ MISSING |
|---|---|---|---|
| Nixos service modules | 24 | 0 | 1 (booklore — sanctioned container) |
| Packages (hugo/beets/video-drivers/swaks/bind) | 6 | 0 | 0 |
| SNM options (accounts/sieve/x509/submission/recipientDelimiter) | 8 | 2 (loginAccounts→accounts, certificateScheme→x509) | 0 |
| VPN-Confinement | 2 | 0 | 0 |
| Postfix | 0 | 1 (extraConfig→settings.main) | 0 |

### Flake lock resolved
- nixpkgs: `531670d` (2026-08-03) — nixos-26.05 branch
- disko: `ff8702b` (2026-06-11) — follows nixpkgs
- sops-nix: `f140661` (2026-07-04) — follows nixpkgs
- vpn-confinement: `b3aa71a` (2026-07-27) — no follows (flake has zero inputs)
- simple-nixos-mailserver: `d357b9f` (2026-07-28) — nixos-26.05 branch (not master!)

### Eval checks
- hostId confirmed `2f69efe2` via `nix eval`
- SNM options confirmed: accounts, x509.useACMEHost, enableSubmissionSsl, recipientDelimiter
- Verification table amended into OpenCode.md header

### Security review (T3 Kimi K3): GO
- No secrets in history. secrets.yaml is ciphertext. age private key outside the repo.
- SSH PasswordAuthentication intentional and documented. .gitignore coverage complete.
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
