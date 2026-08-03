# Changes.md — temporary session log (wiped into OpenCode.md at end of session)

## 2026-08-03 — build step 4 PLANNED (architect): mail stack verification findings

New findings beyond the step-1 verification table (all checked against pinned SNM d357b9f + nixpkgs 26.05):
- ⚠️ NEW RENAME: `mailDirectory` → `mailserver.storage.path` (default `/var/vmail`; owner `virtualMail` uid/gid 5000 auto-created, `createHome=true`). We set `/fast/mail`.
- `mailserver.dkim.enable` defaults to TRUE (selector `mail`, RSA-2048, keys auto-generated into `/var/dkim` by rspamd ExecStartPre; rspamd milter auto-wired into postfix). Zero Nix config needed. DNS TXT read from `/var/dkim/dnanu.de.mail.txt` post-install (1% phase).
- `x509.useACMEHost`: SNM itself sets `security.acme.certs.<name>.reloadServices = [ "dovecot2.service" ]` AND `[ "postfix.service" ]` (dovecot.nix:159, postfix.nix:277). No extraGroups needed — postfix/dovecot read TLS as root before dropping privileges. Our step-3 `reloadServices = [ "nginx" ]` merges untouched.
- `hashedPasswordFile` is read by SNM's genPasswdScript running AS ROOT in dovecot startup → sops secrets stay root:root 0400 default. Add `sops.secrets.mail_{hey,admin}.restartUnits = [ "dovecot2.service" ]` for password rotation.
- `services.postfix.mapFiles` = `attrsOf path` (NOT strings) → sasl_passwd must be a file path. Solution: `sops.templates."postfix-sasl-passwd"` (renders to `/run/secrets/rendered/`, confirmed in pinned sops-nix) + `restartUnits = [ "postfix-setup.service" "postfix.service" ]` so key rotation re-runs postmap.
- Firewall: only TCP 25 added. tailscale0 is trusted → 465/587/993 need zero firewall rules (Tailscale-only by design).
- `sieveScript` = plain lines string; SNM installs it as the account's default.sieve. `require ["fileinto" "mailbox"]` needed for `:create`.

## 2026-08-03 — build step 3 complete: networking stack (tasks 6–10)

### Files created
- `modules/networking/ddclient.nix` — Cloudflare dynamic DNS, 5min interval, webv4 detection
- `modules/networking/acme.nix` — DNS-01 wildcard certs (*.nanulab.de + *.dnanu.de), quad9 resolver bypass
- `modules/networking/nginx.nix` — loopback 8080, placeholder site, recommended settings on
- `modules/networking/cloudflare.nix` — cloudflared tunnel: dnanu.de/www/autoconfig → 127.0.0.1:8080

### Gate results (all passed)
| Task | Check | Result |
|------|-------|--------|
| 6 | ddclient.domains | `[ "mail.dnanu.de" ]` ✅ |
| 7 | acme cert names | `[ "mail.dnanu.de" "nanulab.de" ]` ✅ |
| 7 | nginx.extraGroups | `[ "acme" ]` ✅ |
| 8 | nginx virtualHosts | `[ "dnanu.de" ]` ✅ |
| 9 | cloudflared tunnels | `[ "00000000-0000-0000-0000-000000000000" ]` ✅ |
| 10 | Full `nix build` system closure | ZERO deprecation warnings, 13 derivations built ✅ |

### Bug fix: secrets.yaml key name mismatch
sops.nix declared `mail_hey`/`mail_admin` but secrets.yaml had `mail_hey_hash`/`mail_admin_hash`. Fixed by re-encrypting with correct key names. The `_hash` suffix was an artifact from an older draft — sops-nix doesn't care about key semantics, just that the name matches.

### Configuration.nix imports updated
Added imports for ddclient, acme, nginx, cloudflare modules alongside existing base/adguard/tailscale imports.

### Full system closure
Built `nixos-system-homelab-26.05.20260803.531670d` successfully — includes kernel 6.18.41, ZFS 2.4.3, nginx 1.30.4, Tailscale 1.98.10, Go 1.26.5, sshd 10.4p1, AdGuardHome 0.107.78.

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
