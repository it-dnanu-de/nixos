# TODO — 02 Storage (ZFS + disko)

**Status:** ✅ done (test box, single-disk rpool) · **Owner:** zfs-disko skill · **File refs:** `hosts/homelab/disko.nix`, `hardware-configuration.nix`, `modules/system/zfs.nix`

## Installed (Dell test box)
- [x] disko GPT: 1G ESP `/boot` + ZFS `rpool`
- [x] Datasets: `rpool/nix` (/nix), `rpool/root` (/), `rpool/fast` → `/fast`, `rpool/slow` → `/slow`
- [x] `networking.hostId` set (keep forever)
- [x] `boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages`
- [x] ARC cap via `zfs.zfs_arc_max=1073741824` kernel param (Dell 6GB)

## Directory layout (OpenCode.md §5)
- [ ] `/fast/user/hey/{work/...,academic,downloads}` — human creates via web UIs
- [ ] `/fast/immich` — Immich-managed black box
- [ ] `/fast/mail` — Maildir (SNM creates)
- [ ] `/fast/backups/postgres` — nightly dumps + restic source
- [ ] `/slow/shared-media/video|audio|literature`
- [ ] `/slow/downloads/{qbittorrent,sabnzbd,slskd}` — *arr hardlink source
- [ ] Media dirs `root:media 2775` (setgid) + `media` supplementary group for media services

## Prod migration (future hardware)
- [ ] New `hardware-configuration.nix` (12th-gen i5)
- [ ] New `disko.nix`: pools `fast` (2×4TB SSD RAID1) + `slow` (2×8TB HDD RAID1), same mountpoints
- [ ] Bump `zfsArcMax` (64GB RAM)
- [ ] **Migration contract:** config only references `/fast` + `/slow` abstract paths via settings.nix — nothing else changes

## Verification
- [ ] `zpool status` healthy
- [ ] ARC within cap (`arcstat`/`zfs-stats`)
- [ ] `/fast` + `/slow` mounted at expected paths
