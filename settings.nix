# settings.nix — the single user file (migration contract, OpenCode.md §2)
#
# Every value used by modules is defined here.
# When moving to prod hardware, only this file, disko.nix, and
# hardware-configuration.nix change — everything else stays identical.

{
  hostName = "homelab";

  domains = {
    public = "dnanu.de";          # mail + blogs
    internal = "nanulab.de";     # Tailscale-only services
    mail = "mail.dnanu.de";      # SMTP/IMAP/ManageSieve
  };

  email = {
    hey = "hey@dnanu.de";        # primary mailbox
    admin = "admin@dnanu.de";    # services admin
    acme = "admin@dnanu.de";     # Let's Encrypt registration
  };

  network = {
    interface = "enp10s0";       # verified on Dell live-ISO, prod may differ
    address = "10.0.0.2";
    prefixLength = 24;
    gateway = "10.0.0.1";
    tailscaleRoutes = "10.0.0.0/24";
  };

  hostId = "2f69efe2";           # ZFS requires stable host ID — generate once, keep forever

  zfsArcMax = "1073741824";      # 1 GiB on the Dell's 6 GB; bump to 8–16 GiB on prod

  paths = {
    fast = "/fast";              # SSD pool (or dataset) — apps, databases, mail
    slow = "/slow";              # HDD pool — media, downloads
  };

  vpn = {
    forwardedPort = 0;           # placeholder — human sets from AirVPN dashboard (1% manual)
  };

  sshPubKey = "ssh-ed25519 AAAA… placeholder";  # human populates with their real key
  # Note: SSH password authentication remains enabled — intentional by human ruling.

  timeZone = "Europe/Berlin";
}
