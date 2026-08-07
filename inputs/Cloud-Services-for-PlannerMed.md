# Task: Cloud Services — Nextcloud + Collabora + Immich + Vaultwarden (build step 5) — for planner-med

Source: OpenCode.md §9 service map (✅ verified in pinned nixos-26.05), §12 build order step 5,
TODO/06-Cloud-Services. Created by Flash per Session Workflow 2026-08-08.
**Tier: Medium (planner-med)** — 4 services, multi-file module creation + service config.
Execution after plan approval: nixos-builder (DeepSeek V4 Pro).

## Context / why now
Foundation/Storage/Networking/Mail/Identity are done and deployed (gen 72), mail verified green.
Per the frozen build order the next milestone is the private-cloud tier. All four services are
native NixOS modules in pinned 26.05 (§9 flags ✅ verified). The Dell (6GB RAM, i5-2520M) is
the test box — RAM is the binding constraint (Immich, Nextcloud+Collabora heaviest).

## Services to plan (exact spec from OpenCode.md §9)

### Nextcloud — `services.nextcloud`
- vhost `cloud.nanulab.de` (VPN-only, user-tier ACL)
- Native PostgreSQL + Redis
- `extraApps`: mail, calendar, contacts
- `adminpassFile` = sops `nextcloud_admin_pass` (currently REPLACE_ME)
- `maxUploadSize = "16G"`
- CalDAV/CardDAV/WebDAV endpoints must work for the iOS mobile profile (OpenCode.md §10 payload)
- `services.postgresqlBackup` nightly dump → `/fast/backups/postgres`
- Media group: nextcloud gets supplementary `media` group (OpenCode.md §5)

### Collabora Online — `services.collabora-online`
- vhost `office.nanulab.de` (VPN-only)
- Nextcloud Office backend (Nextcloud `office` app points at local coolwsd)
- Native module, verify exact option names in pinned 26.05

### Immich — `services.immich`
- vhost `photos.nanulab.de` (VPN-only)
- `mediaLocation = /fast/immich`
- **Machine learning disabled** on Dell (CPU too weak)
- Postgres (immich has its own db); nightly dump
- Media group

### Vaultwarden — `services.vaultwarden`
- vhost `vault.nanulab.de` (VPN-only)
- `SIGNUPS_ALLOWED = false`
- `admin_token` from sops `vaultwarden_admin_token` (currently REPLACE_ME)

## Cross-cutting requirements
- Each service gets an nginx user-tier vhost (reuse `mkUserVhost` in `modules/networking/nginx.nix`)
- All vhosts `*.nanulab.de` → VPN-only; DNS resolved by AdGuard split-horizon rewrite already in place
- sops secrets: fill `nextcloud_admin_pass` + `vaultwarden_admin_token` (human must supply plaintext values — mark as human step, don't invent)
- Modules land in `modules/services/{nextcloud,immich,vaultwarden,collabora}.nix` (or one `cloud-services.nix` — planner decides), imported from `hosts/homelab/configuration.nix`
- Restic include: `/var/lib` state for each service (backup module comes later in step 8, just note the path)
- Postgres: likely one `services.postgresql` instance shared (nextcloud, immich) + vaultwarden may use its own or sqlite — verify module defaults in 26.05
- RAM budget on Dell: ARC capped 1GB, 6GB total — flag if any service needs tuning

## Human steps (do NOT automate, just flag in plan)
- Provide plaintext `nextcloud_admin_pass` + `vaultwarden_admin_token` values for sops
- Create Nextcloud admin account + link Mail app to local IMAP (1% manual, §12)
- Vaultwarden admin portal setup

## Deliverable
`outputs/Cloud-Services-plan-by-*.md` — concrete per-service plan: exact module options
(verified against pinned 26.05), nginx vhost snippets, sops additions, import wiring, deploy
order (service-by-service with verification between), and the RAM-budget note.
