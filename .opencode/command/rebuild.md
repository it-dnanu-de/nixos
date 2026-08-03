---
description: Rebuild the NixOS system on the server from the latest committed config.
agent: deployer
---

Rebuild the NixOS system on the homelab server (10.0.0.2) from the latest committed config in /etc/nixos.

$ARGUMENTS

Ensure the repo on the server is pulled to HEAD, run `nixos-rebuild switch --flake .#homelab`, roll back on failure, and report the generation. If a `--dry-run` is wanted, mention it in the arguments.
