# nixos — nanulab homelab

A 20-year NixOS homelab for **dnanu.de**. Single node, single user, 99% declarative, pinned to the `nixos-26.05` stable channel.

> **[OpenCode.md](OpenCode.md) is the single source of truth.** Build, rule, and verification decisions live there. All ⚠️ VERIFY flags have been checked against pinned `nixos-26.05` and are marked ✅ verified.

## What this repo is
- The complete NixOS configuration for the homelab server: `flake.nix`, `settings.nix`, sops-encrypted `secrets/secrets.yaml`, `hosts/homelab`, and modular config under `modules/`.
- ZFS + disko storage (`/fast`, `/slow`), a split-horizon DNS setup (AdGuard + Tailscale), a full mail stack (simple-nixos-mailserver + Resend relay), and a "feels like Netflix" media pipeline (Seerr -> \*arr -> Jellyfin/Navidrome/ABS/Booklore), all behind a zero-open-ports network (except 25/tcp).
- ~25 native NixOS services. One sanctioned container exception: Booklore.

## Agent tooling (opencode)
This repo ships with an opencode configuration so AI agents work the way this project wants:

| Piece | Where | What it does |
|---|---|---|
| Main config | `opencode.json` | instructions, MCP servers, references, permissions |
| Agents | `.opencode/agent/` | `architect` (T3 Kimi K3), `nixos-builder` (T2 DeepSeek V4 Pro), `verifier` (T1 DeepSeek V4 Flash), `security-reviewer` (T3 Kimi K3), `deployer` (T2 DeepSeek V4 Pro) |
| Commands | `.opencode/command/` | `/init`, `/deploy`, `/rebuild`, `/verify`, `/update`, `/secrets`, `/commit`, `/pr`, `/status` |
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
- **Phase:** Build step 2 complete (`disko.nix` + `hardware-configuration.nix` + ZFS module).
- **What works:** Single-disk ZFS layout (1G ESP + rpool: root/nix/fast/slow) targeting `/dev/disk/by-id` (never the USB stick). Dell E5520 kernel modules detected from live ISO. ARC capped at 1GiB. systemd-boot EFI. Lid switch ignores (native 26.05 logind path). Eval gate passed: all 5 filesystems confirmed, no deprecation warnings.
- **Next milestone:** Build step 3 — Networking: static IP, AdGuard, Tailscale, ddclient, cloudflared, nginx + ACME.

## License
See [LICENSE](LICENSE).
