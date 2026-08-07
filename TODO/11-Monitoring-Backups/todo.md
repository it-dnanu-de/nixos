# TODO — 11 Monitoring & Backups

**Status:** ⬜ not started (build step 8) · **Owner:** nixos-builder · **Modules:** `modules/services/monitoring.nix`, `modules/system/backups.nix`

## Beszel (`services.beszel.hub` + `.agent`)
- [ ] `status.nanulab.de` (VPN-only)
- [ ] hub + agent modules (26.05 ✅ verified)
- [ ] Agent monitors systemd units; mail-queue alert integration
- [ ] Agent key (1% manual pairing)

## Restic → Backblaze B2 (OpenCode.md §11)
- [ ] `services.restic.backups.b2` module
- [ ] `passwordFile` + `environmentFile` (B2 creds) from sops
- [ ] **Include:** `/fast` (Nextcloud files, Immich, Maildir, dumps), `/var/lib` app state for all §9 services, `/etc/nixos`
- [ ] **Exclude:** `/slow/shared-media`, `/slow/downloads`, caches
- [ ] Source = ZFS snapshot (crash-consistent) + postgres dumps
- [ ] Prune: 7 daily / 4 weekly / 12 monthly
- [ ] `restic check` in verification
- [ ] Restore drill documented + tested once (§12)

## PostgreSQL backups
- [ ] `services.postgresqlBackup` nightly: nextcloud, immich (+ booklore mariadb dump) → `/fast/backups/postgres`

## Health
- [ ] `systemctl --failed` empty in §13 suite
