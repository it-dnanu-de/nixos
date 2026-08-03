---
description: Open the sops-encrypted secrets/secrets.yaml for editing (requires the age key + sops on the server or this machine).
agent: nixos-builder
---

Edit the sops-encrypted secrets file for the homelab.

$ARGUMENTS

Locate the age key (on USB / password manager — do NOT copy it into the repo), then:
1. `sops secrets/secrets.yaml` (or `sops edit`), or on the server `sudo sops /etc/nixos/secrets/secrets.yaml`.
2. Add/change the requested secret and update the secrets inventory in OpenCode.md §7 if you add a new key.
3. Never commit decrypted values. The encrypted file is safe to commit.

Target secret / action: $ARGUMENTS
