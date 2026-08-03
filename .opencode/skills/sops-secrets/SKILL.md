---
name: sops-secrets
description: Use whenever a secret is needed — API tokens, mail hashes, wifi keys, OAuth creds, admin passwords. Enforces sops-nix + age, the public-safe repo rule, and the secrets inventory.
---

# sops-nix Secrets Management

## Model (OpenCode.md §7)
- Secrets live in `secrets/secrets.yaml`, sops-encrypted, safe to commit to the public repo.
- Private age key lives on a USB drive + password manager. **Never** in the repo, never in `/nix/store` (world-readable).
- `.sops.yaml` at repo root maps files to the age public key.

## Secrets inventory (OpenCode.md §7)
`cloudflare_api_token`, `cloudflared_tunnel_cred`, `resend_api_key`, `mail_hey_hash`, `mail_admin_hash`, `tailscale_oauth`, `airvpn_wg_conf`, `b2_account_id`, `b2_account_key`, `restic_password`, `nextcloud_admin_pass`, `vaultwarden_admin_token`, `slskd_env` (`SLSKD_SLSK_USERNAME/PASSWORD`), `profile_basic_auth`, `mobileca_key`, `mobileca_cert`, `booklore_db_password`.

## Workflow
1. Edit: `sops secrets/secrets.yaml` (age key needed; use the `secrets` command).
2. Reference from Nix via `config.sops.secrets.<name>.path`.
3. Services consume secrets via `passwordFile`, `environmentFile`, or sops templates — never inline values in modules.
4. Postfix relay password uses a sops *template* (`.sops.yaml` `creation_rules` template) rendered mode-0600 to `/etc/postfix/sasl_passwd`.

## Guardrails
- Never commit a decrypted value. If you're about to, stop.
- New secret added -> update the inventory in OpenCode.md §7.
- Tailscale uses an OAuth client secret (tagged `tag:server`) in sops -> `services.tailscale.authKeyFile`, because pre-auth keys expire in <=90 days.
- The mobile CA key/cert (`mobileca_*`) is generated on the Mac, stored in sops, and signed into the `.mobileconfig` at build time by a systemd oneshot — never generated in a Nix build.
