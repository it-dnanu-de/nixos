# nixos — nanulab homelab

A 20-year NixOS homelab for **dnanu.de**. Single node, single user, 99% declarative, pinned to the `nixos-26.05` stable channel.

> **[OpenCode.md](OpenCode.md) is the single source of truth.** Build, rule, and verification decisions live there. All ⚠️ VERIFY flags have been checked against pinned `nixos-26.05` and are marked ✅ verified.

## What this repo is
- The complete NixOS configuration for the homelab server: `flake.nix`, `settings.nix`, sops-encrypted `secrets/secrets.yaml`, `hosts/homelab`, and modular config under `modules/`.
- ZFS + disko storage (`/fast`, `/slow`), a split-horizon DNS setup (AdGuard + WireGuard VPN), a full mail stack (simple-nixos-mailserver + Resend relay), and a "feels like Netflix" media pipeline (Seerr -> \*arr -> Jellyfin/Navidrome/ABS/Booklore), all behind a minimal-exposure network (25/tcp + 51820/udp only).
- ~25 native NixOS services. One sanctioned container exception: Booklore.

## Agent tooling (opencode)
This repo ships with an opencode configuration so AI agents work the way this project wants:

| Piece | Where | What it does |
|---|---|---|
| Main config | `opencode.json` | instructions, MCP servers, references, permissions |
| Agents | `.opencode/agent/` | `planner-low` (V4 Flash), `planner-med` (V4 Pro), `planner-high` (GLM 5.2), `planner-max` (Kimi K3), `nixos-builder`/executor (V4 Pro), `verifier` (V4 Flash), `security-reviewer` (Kimi K3), `deployer` (V4 Pro) |
| Commands | `.opencode/command/` | `/task` (general workflow), `/init`, `/deploy`, `/rebuild`, `/verify`, `/update`, `/secrets`, `/commit`, `/pr`, `/status`, `/review` |
| Skills | `.opencode/skills/` | nixos-flake, sops-secrets, mail-stack, zfs-disko, deployment, verification, security-hardening, git-workflow |
| References | `@nixpkgs @snm @disko @sops-nix @nixos-anywhere @vpn-confinement` | pinned-channel verification sources |

MCP servers: **context7** (option lookup), **github** (disabled — GitHub's managed endpoint can't do opencode OAuth; use the `gh` CLI), **ssh-homelab** (`@fangjunjie/ssh-mcp-server` -> 10.0.0.2, password via the `HOMELAB_SSH_PASSWORD` env var — see Memory.md), **playwright** (browser-verifying UIs). The two `npx`-based ones need `nodejs`/`npm` installed (`sudo pacman -S nodejs npm`); the remote ones work without.

## Starting a session — `Init`
Launch opencode in this directory and type `/init`. It:
1. Probes the environment (repo state, toolchain, whether 10.0.0.2 is reachable, MCP server health).
2. Asks you a short batch of setup questions (server reachable? which milestone? secrets ready?).
3. Routes work across the model tiers: `architect` for planning, `nixos-builder` for writing config, `verifier` for checking options against pinned 26.05, `security-reviewer` for audits, `deployer` for rebuilds.
4. Drives the frozen build order (OpenCode.md §12), pausing for your approval at each milestone.

Prereqs for a live session: `HOMELAB_SSH_PASSWORD` must be set in the shell **before** launching opencode. It's exported automatically in fish via `~/.config/fish/conf.d/homelab.fish` (and was in `~/.bashrc`), and the NixOS live ISO booted with sshd running.

## Status
- **Phase:** v2 access control (re-addressing, Authelia, profile.dnanu.de, nginx ACL helpers) built, pending deploy.
- **What works in repo:** Static IP `10.0.0.2/24` on enp10s0. AdGuard Home DNS + DHCP (v2 re-addressing: 9 named users at 10.0.0.8-20, guest range .50-.250, persistent clients keyed by user). Declarative WireGuard VPN (`vpn.dnanu.de:51820`, 13 peers with admin/user tiers). Per-user QR renderer (per-user index with tier notes → /var/lib/mobileprofile/wg/<user>/). ddclient Cloudflare dynamic DNS for `mail.dnanu.de` + `vpn.dnanu.de`. ACME DNS-01 wildcard certs for `*.nanulab.de` + `*.dnanu.de`. nginx loopback-only on 8080 (placeholder site). cloudflared tunnel for `dnanu.de`/`www`/`autoconfig`/`profile.dnanu.de`. Authelia (TOTP 2FA, file auth, 9 users) guarding profile.dnanu.de. nginx mkAdminVhost/mkUserVhost ACL helpers for future service vhosts. Full system closure builds with zero deprecation warnings.
- **Deployed (10.0.0.2 gen 35):** WireGuard VPN swap (2026-08-06). AdGuard split-horizon DNS. `*.nanulab.de` public A records deleted. profile.nanulab.de/wg/ with shared basic auth (v2 not yet deployed).
- **Next milestone:** Deploy v2 after human approves → then Build step 4 (Mail: SNM + Resend relay + sieve rules + DNS records).

## License
See [LICENSE](LICENSE).
