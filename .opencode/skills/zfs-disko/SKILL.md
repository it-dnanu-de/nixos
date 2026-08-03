---
name: zfs-disko
description: Use when dealing with storage — disko partitioning, ZFS pools/datasets, ARC tuning, backup sources, or the /fast /slow layout. Enforces the migration contract.
---

# ZFS + Disko Storage

## Layout (OpenCode.md §5)
- Test box: single 250GB SSD, GPT: 1G ESP `/boot` + rest ZFS `rpool`.
- Prod: `fast` pool (2x4TB NVMe/SSD RAID1) + `slow` pool (2x8TB HDD RAID1), same mountpoints.
- Datasets: `rpool/nix` (/nix), `rpool/root` (/), `rpool/fast` -> /fast, `rpool/slow` -> /slow.

## Directory tree
```
/fast/user/hey/{work/{audio,video,images,literature,documents}/{apple,windows,linux},academic,downloads}
/fast/immich        # Immich-managed, black box
/fast/mail          # Maildir
/fast/backups/postgres
/slow/shared-media/video/{shows,movies}
/slow/shared-media/audio/{music,audiobooks,podcasts}
/slow/shared-media/literature/{books,comics,manga}
/slow/downloads/{qbittorrent,sabnzbd,slskd}
```
- Media services + nextcloud + immich get supplementary group `media`; dirs `root:media 2775` (setgid).

## Mandatory settings
- `networking.hostId = "<8 hex>";` — generate once, keep forever.
- `boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;`
- ARC cap is a `settings.nix` parameter; Dell default `zfs.zfs_arc_max=1073741824`.

## Migration contract (the point of all this)
Config references abstract paths `/fast` and `/slow` via `settings.nix` only.
Moving to prod = new `hardware-configuration.nix` + new `disko.nix` (two pools, same mountpoints) + bump `zfsArcMax`. Nothing else changes.

## Backups coupling
- `/fast/backups/postgres` = nightly `services.postgresqlBackup` (nextcloud, immich) -> restic source.
- Restic includes `/fast`, `/var/lib` service state, `/etc/nixos`. Excludes `/slow/shared-media`, `/slow/downloads`, caches. Prune 7d/4w/12m to B2.
