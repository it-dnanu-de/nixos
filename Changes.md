# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

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
