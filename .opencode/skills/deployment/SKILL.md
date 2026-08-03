---
name: deployment
description: Use when installing, deploying, rebuilding, or rollback on the NixOS server — nixos-anywhere first install, ssh-based nixos-rebuild, and the rollback path.
---

# Deployment

## Environment
- This dev machine: Arch Linux, **no `nix` installed**. All nix tooling runs on the server.
- Server: `10.0.0.2/24` static, gw `10.0.0.1`, users `nixos` / `root` (password SSH allowed by design — never disable it).
- Connect via `ssh` (bash) or the `ssh-homelab` MCP server.

## First install (nixos-anywhere, OpenCode.md §12)
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#homelab --extra-files <dir-with-age-key> root@10.0.0.2
```
Preconditions: live ISO booted on the Dell, sshd running, passwords set (see Memory.md), disko will format.

## Day-2 rebuild
```bash
cd /etc/nixos && sudo git pull && sudo nixos-rebuild switch --flake .#homelab
```
- Pre-flight `sudo nix flake check` for risky changes.
- If switch fails: capture error, `sudo nixos-rebuild switch --rollback`, report. Rollback also via boot menu.

## Rules
- Never leave the server half-switched. Deploy = sync repo -> verify -> switch -> smoke-test -> report generation.
- The "1% manual" after install (OpenCode.md §12): approve Tailscale subnet route; Nextcloud admin + link Mail app to local IMAP; Jellyfin/Navidrome/ABS/Booklore admin accounts + libraries; Prowlarr indexers; connect *arrs to qBittorrent/SABnzbd/slskd; Seerr<->Jellyfin; Vaultwarden admin; HA onboarding; Beszel agent key.
- Keep credentials in Memory.md (gitignored), never in the repo.
