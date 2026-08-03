# modules/system/zfs.nix
# OpenCode.md §5 — ZFS system config.
# hostId (required by zfs module) is already set in configuration.nix from
# settings.hostId. Disko adds the zfs filesystems — nothing else to declare.
{ settings, ... }:
{
  # ARC cap: Dell has ~5.7 GiB RAM — keep ZFS on a 1 GiB diet (settings.zfsArcMax).
  # Kernel-cmdline form applies from first module load, initrd included.
  boot.kernelParams = [ "zfs.zfs_arc_max=${settings.zfsArcMax}" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = false;
}
