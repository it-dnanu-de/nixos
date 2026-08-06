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
- **Phase:** Enterprise mail hardening — MTA-STS/TLS-RPT/DANE TLSA, postfix+rspamd hardening, DKIM sync fixed, queue watchdog. Built and committed (2026-08-06). Pending deploy approval.
- **What works in repo:** Static IP `10.0.0.2/24` + ULA `fd10::2/64` on enp10s0. AdGuard Home DNS-only (DHCP retired to Kea, v4: persistent clients via isPeer filter + infra entry, bind_hosts on IPv4+IPv6, `runtime_sources.dhcp=false`). Kea DHCPv4 (pool `.100-.200`, 10 host reservations from users.nix + Kea DHCPv6 (stateful ULA pool `fd10::100-200`, DNS=`fd10::2`). Declarative WireGuard VPN (`vpn.dnanu.de:51820`, **97 peers** at `10.0.10.0/24` with `[user]+[user]1-9-vpn` naming, full pre-provision — 13 keys renamed from v3, 84 freshly generated, 194 sops keys). Per-user QR renderer (per-user dirs → /var/lib/mobileprofile/wg/<user>/; admin=7 QRs, users=10 QRs each). ddclient Cloudflare DNS for `mail.dnanu.de` + `vpn.dnanu.de`. ACME DNS-01 wildcard certs for `*.nanulab.de` + `*.dnanu.de`. nginx loopback-only on 8080 (placeholder site) + catch-all 404 on 0.0.0.0:443 (dead-name fix). cloudflared tunnel for `dnanu.de`/`www`/`autoconfig`/`mta-sts`/`profile.dnanu.de`. Authelia (one_factor, file auth, 10 users) guarding profile.dnanu.de. nginx ACL v4 (isPeer-filtered allowlists, guests denied). **Mail hardening (new):** SNM + Resend relay + verified TLS outbound + postfix RFC-conformance restrictions + rspamd reject=12 + TLS-RPT reporting + DMARC aggregate reporting + MTA-STS enforce policy + DANE TLSA 3 1 1 auto-sync + DKIM fix (idempotent, self-healing) + queue/service watchdog. Full system closure builds with zero new warnings.
- **Deployed (10.0.0.2 gen 45):** Homelab v2 access control (Authelia, profile.dnanu.de, nginx ACL v2). AGH DNS active. WG at 10.0.1.x (old subnet).
- **Next milestone:** Deploy v4 after human approves → then Build step 4 (Mail: SNM + Resend relay + sieve rules + DNS records).

## License
See [LICENSE](LICENSE).
