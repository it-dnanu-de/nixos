# TODO — 06 Cloud Services

**Status:** ⬜ not started (next milestone) · **Owner:** nixos-builder + planner-med/high · **Modules to create:** `modules/services/nextcloud.nix`, `immich.nix`, `vaultwarden.nix`, `collabora.nix` (+ nginx vhosts)

> Build step 5 in OpenCode.md §12. All options/packages verified in pinned 26.05 (see §9). RAM-heavy four on the Dell: Immich, Nextcloud+Collabora, Jellyfin, Booklore.

## Nextcloud (`services.nextcloud`)
- [ ] Module: `services.nextcloud`, hostname `cloud.nanulab.de` (VPN-only)
- [ ] Native PostgreSQL + Redis
- [ ] `extraApps`: mail, calendar, contacts
- [ ] `adminpassFile` from sops
- [ ] `maxUploadSize = "16G"`
- [ ] nginx user-tier vhost + ACL
- [ ] CalDAV/CardDAV/WebDAV endpoints for mobile profile
- [ ] Nextcloud Mail app linked to local IMAP (1% manual)
- [ ] `postgresqlBackup` nightly dump to `/fast/backups/postgres`

## Collabora Online (`services.collabora-online`)
- [ ] Module exists in 26.05 (✅ verified per §9)
- [ ] `office.nanulab.de` (VPN-only) as Nextcloud Office backend
- [ ] Heavy on Dell 6GB — accepted

## Immich (`services.immich`)
- [ ] `photos.nanulab.de` (VPN-only)
- [ ] `mediaLocation = /fast/immich`
- [ ] ML **disabled** on Dell (CPU too weak)
- [ ] Postgres + nightly dump
- [ ] Admin account (1% manual)

## Vaultwarden (`services.vaultwarden`)
- [ ] `vault.nanulab.de` (VPN-only)
- [ ] `SIGNUPS_ALLOWED = false`
- [ ] `admin_token` from sops
- [ ] Admin portal setup (1% manual)

## Shared
- [ ] Add nginx vhosts for each (user-tier ACL)
- [ ] Add all to restic include (`/var/lib` state) — check §11 excludes
- [ ] `media` group for services that touch /fast
