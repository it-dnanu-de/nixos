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
    vpn = "vpn.dnanu.de";        # WireGuard endpoint (grey cloud, ddclient-managed)
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
    subnet = "10.0.0.0/24";      # LAN — allowed to reach local nginx TLS vhosts (AdGuard UI, profile)
    gateway = "10.0.0.1";
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

  # WireGuard remote-access VPN (OpenCode.md §3.3). Server 10.0.1.1/24, endpoint vpn.dnanu.de:51820.
  # v2 (2026-08-06): two-tier — `admin = true` peers reach ALL *.nanulab.de incl. admin UIs;
  # `admin = false` (user) peers reach user-facing services only. Enforcement = nginx source-IP
  # allowlist by peer IP. Guests have NO WG peer. Peer name = [user]-[device]-vpn.
  # Public keys are not secret; private keys + PSKs live in sops (wireguard_peer_<name>_{private,psk}).
  network.wireguard = {
    port = 51820;
    subnet = "10.0.1.0/24";
    address = "10.0.1.1";
    endpoint = "vpn.dnanu.de";
    peers = [
      # Admin (Dumitru) — reaches ALL *.nanulab.de incl. admin UIs
      { name = "dumitru-phone-vpn"; ip = "10.0.1.8";  admin = true;  user = "dumitru"; publicKey = "hgUar95LcXopyebZfGRDbe0lZndqDfHDp/1CiSg1qlo="; }
      { name = "dumitru-pc-vpn";    ip = "10.0.1.9";  admin = true;  user = "dumitru"; publicKey = "iMocXpOjXHN0dEyOZqoPU0WHk99DZlEGs7vJePwfHgo="; }
      # User peers — user-facing services only
      { name = "adela-phone-vpn";   ip = "10.0.1.10"; admin = false; user = "adela";   publicKey = "IKGIZcEp5jXPPhjD1y0yhH8NctiJOlCC0WEto6hNC2U="; }
      { name = "adela-tv-vpn";      ip = "10.0.1.11"; admin = false; user = "adela";   publicKey = "WppvW2HLCQEl+7Q5CmSSKk9XOzAgf3wImZvGTGTGF1o="; }
      { name = "adela-air-vpn";     ip = "10.0.1.12"; admin = false; user = "adela";   publicKey = "mLGb/B4MTy7lebFCtSsPLyZet2g/7RhVs2VGYw5lTFw="; }
      { name = "tiberiu-phone-vpn"; ip = "10.0.1.13"; admin = false; user = "tiberiu"; publicKey = "021YHQrkW0jelFHbRaAYhMXr13XkC52MYFCTlMac3h8="; }
      { name = "david-phone-vpn";   ip = "10.0.1.14"; admin = false; user = "david";   publicKey = "N/+2L7/gr4cNXh5QWlHlU/HP3JELEPq3yRqJiHRdm2A="; }
      { name = "david-xbox-vpn";    ip = "10.0.1.15"; admin = false; user = "david";   publicKey = "vvL7s3DRtfeQPWFNG6rdh0g9+aCb2EuAePA9ytfo6iE="; }
      { name = "ramona-phone-vpn";  ip = "10.0.1.16"; admin = false; user = "ramona";  publicKey = "4FNungU+bh000Xl1iK9M/IF6nyogsExGBxijnEQfIDc="; }
      { name = "tibisor-phone-vpn"; ip = "10.0.1.17"; admin = false; user = "tibisor"; publicKey = "ACCujN9Qv0tt9TGW70faDP9lnMck7EFHa5dk/T5UMDU="; }
      { name = "iza-phone-vpn";     ip = "10.0.1.18"; admin = false; user = "iza";     publicKey = "nBHQHSFHU/24IeKEJ0rFsV2xJTZCc4sRW/sI5/if+kc="; } # MAC TODO
      { name = "kerem-phone-vpn";   ip = "10.0.1.19"; admin = false; user = "kerem";   publicKey = "zSoQM300aEExAnjUDwjHZi9r5tfrwsm4drEtrqVp90c="; } # MAC TODO
      { name = "hannah-phone-vpn";  ip = "10.0.1.20"; admin = false; user = "hannah";  publicKey = "iRSXSbB/aiqXxRUyMLc2zfaJ+uARS9Jh5WOBwfQYkwU="; } # MAC TODO
    ];
  };

  sshPubKey = "ssh-ed25519 AAAA… placeholder";  # human populates with their real key
  # Note: SSH password authentication remains enabled — intentional by human ruling.

  cloudflare = {
    tunnelId = "00000000-0000-0000-0000-000000000000"; # placeholder — human sets real tunnel UUID (1% manual)
  };

  timeZone = "Europe/Berlin";
}
