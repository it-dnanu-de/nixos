---
description: Run the quarterly nix flake update workflow (human-approved, deliberate).
agent: nixos-builder
---

Run the quarterly flake update workflow from OpenCode.md §14.

$ARGUMENTS

1. On the server (where nix lives): `cd /etc/nixos && sudo nix flake update`.
2. Review the resulting `flake.lock` diff — list the version bumps and flag any concerning jumps.
3. Build and test before switching: `sudo nixos-rebuild dry-run --flake .#homelab`.
4. Report the summary to the human and wait for approval before doing the switch. Rollback path is boot menu / flake.lock git history. No unattended upgrades.
