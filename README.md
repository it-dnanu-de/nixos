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
- **Phase:** Kimi K3 security audit implemented (2026-08-07). Host firewall now enforces §3.2 at the server layer: only 25/tcp + 51820/udp are globally open; all other service ports are source-scoped to LAN/ULA/link-local (audit Finding 1). DNS upsert fixed (multi-record clobber guard), DNS sync has --fail/timer convergence, TLSA-sync wired to Resend alert, watchdog/template/docs cleaned up. Full system closure builds with zero warnings.
- **What works in repo:** Static IP `10.0.0.2/24` + ULA `fd10::2/64` on enp10s0. AdGuard Home DNS-only (DHCP retired to Kea). Kea DHCPv4 (pool `.100-.200`, 10 host reservations) + Kea DHCPv6 (stateful ULA pool `fd10::100-200`, DNS=`fd10::2`). Declarative WireGuard VPN (`vpn.dnanu.de:51820`, **97 peers** at `10.0.10.0/24`, 194 sops keys). Per-user QR renderer. ddclient Cloudflare DNS. ACME DNS-01 wildcard certs. nginx catch-all 404. cloudflared tunnel. Authelia (10 users). nginx ACL v4. **Mail:** SNM + Resend relay (verified TLS, static tls_policy) + postfix RFC-conformance + rspamd reject=12 + TLS-RPT + DMARC reporting + MTA-STS enforce + DANE TLSA 3 1 1 (auto-synced, ACME hook + daily timer) + DKIM (idempotent parser, Restart=on-failure) + queue/service watchdog + TLSA-failure alert. **Firewall:** 25/tcp + 51820/udp globally open; 53/80/443/465/587/993 scoped to LAN/ULA/link-local at the host (iptables extraCommands).
- **Deployed (10.0.0.2 gen 45):** Homelab v2 access control (Authelia, profile.dnanu.de, nginx ACL v2). AGH DNS active. WG at 10.0.1.x (old subnet).
- **Next milestone:** Deploy v4 after human approves → then Build step 4 (Mail: SNM + Resend relay + sieve rules + DNS records).

## License
See [LICENSE](LICENSE).
