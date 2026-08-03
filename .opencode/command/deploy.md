---
description: Deploy the current repo config to the homelab server and rebuild. Optionally take a target like "hosts/homelab".
agent: deployer
---

Deploy the current repository state to the homelab server (10.0.0.2) and rebuild.

Target scope: $ARGUMENTS

Follow the deployment checklist: verify reachability, sync the repo on the server, run `nixos-rebuild switch` (or nixos-anywhere for a first install), roll back on failure, then run the relevant §13 verification checks. Report the new generation and any manual steps the human still needs.
