# hosts/homelab/configuration.nix
# Minimal eval-able stub — modules fill in services, networking, storage, etc.
# Expanded in subsequent build phases per OpenCode.md §12 frozen build order.

{
  settings,
  ...
}:

{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/system/zfs.nix
    ../../modules/system/sops.nix
    ../../modules/networking/base.nix
    ../../modules/networking/adguard.nix
    ../../modules/networking/tailscale.nix
    ../../modules/networking/ddclient.nix
    ../../modules/networking/acme.nix
    ../../modules/networking/nginx.nix
    ../../modules/networking/cloudflare.nix
    ../../modules/system/users.nix
  ];

  # Dell quirk (§2): lid closed ≠ suspend — the battery is a free UPS.
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  networking.hostName = settings.hostName;
  networking.hostId = settings.hostId;

  system.stateVersion = "26.05";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = true;
}
