# nixos — nanulab homelab

A 20-year NixOS homelab for **dnanu.de**. Single node, single user, 99% declarative, pinned to the `nixos-26.05` stable channel.

> **[OpenCode.md](OpenCode.md) is the single source of truth.** Build, rule, and verification decisions live there. Anything marked ✅ LOCKED is final; ⚠️ VERIFY must be checked against the pinned channel before use.

## What this repo is
- The complete NixOS configuration for the homelab server: `flake.nix`, `settings.nix`, sops-encrypted `secrets/secrets.yaml`, `hosts/homelab`, and modular config under `modules/`.
- ZFS + disko storage (`/fast`, `/slow`), a split-horizon DNS setup (AdGuard + Tailscale), a full mail stack (simple-nixos-mailserver + Resend relay), and a "feels like Netflix" media pipeline (Seerr -> \*arr -> Jellyfin/Navidrome/ABS/Booklore), all behind a zero-open-ports network (except 25/tcp).
- ~25 native NixOS services. One sanctioned container exception: Booklore.

## Agent tooling (opencode)
This repo ships with an opencode configuration so AI agents work the way this project wants:

| Piece | Where | What it does |
|---|---|---|
| Main config | `opencode.json` | instructions, MCP servers, references, permissions |
| Agents | `.opencode/agent/` | `architect` (T3), `nixos-builder` (T2), `verifier`, `security-reviewer`, `deployer` |
| Commands | `.opencode/command/` | `/deploy`, `/rebuild`, `/verify`, `/update`, `/secrets`, `/commit`, `/pr`, `/status` |
| Skills | `.opencode/skills/` | nixos-flake, sops-secrets, mail-stack, zfs-disko, deployment, verification, security-hardening, git-workflow |
| References | `@nixpkgs @snm @disko @sops-nix @nixos-anywhere @vpn-confinement` | pinned-channel verification sources |

MCP servers: **context7** (option lookup), **github** (OAuth), **ssh-homelab** (`@fangjunjie/ssh-mcp-server` -> 10.0.0.2), **playwright** (browser-verifying UIs). The three `npx`-based ones need `nodejs`/`npm` installed (`sudo pacman -S nodejs npm`); the remote ones work without.

## Status
- **Phase:** pre-build. Repo bootstrapped, tooling in place.
- **What works:** nothing deployed yet — this is the blueprint + build session.
- **Known gaps / coming:** everything in OpenCode.md §9-15 (see the frozen build order §12). The first milestone is the ⚠️ VERIFY table against pinned `nixos-26.05`.

## License
See [LICENSE](LICENSE).
