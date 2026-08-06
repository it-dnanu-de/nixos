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
    # Admin LAN IPs are now derived from users.nix (admin block 10.0.0.3-8).
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

  # WireGuard remote-access VPN (OpenCode.md §3.3, v3 10.0.10.0/24).
  # Server 10.0.10.2/24, endpoint vpn.dnanu.de:51820.
  # Peers are now DERIVED from users.nix (hostname-vpn naming, e.g. admin3-vpn, dumitru1-vpn).
  # Public keys are mapped per-device hostname below; private keys + PSKs live in sops
  # (wireguard_peer_<hostname>-vpn_{private,psk}).
  network.wireguard = {
    port = 51820;
    subnet = "10.0.10.0/24";
    address = "10.0.10.2";
    endpoint = "vpn.dnanu.de";
    # Public keys per-device hostname (public — safe in git).
    # Mapping from old peer names (v2) to new hostname-vpn naming (v3).
    peerPublicKeys = {
      admin3    = "iMocXpOjXHN0dEyOZqoPU0WHk99DZlEGs7vJePwfHgo=";
      dumitru1  = "hgUar95LcXopyebZfGRDbe0lZndqDfHDp/1CiSg1qlo=";
      adela1    = "IKGIZcEp5jXPPhjD1y0yhH8NctiJOlCC0WEto6hNC2U=";
      adela2    = "WppvW2HLCQEl+7Q5CmSSKk9XOzAgf3wImZvGTGTGF1o=";
      adela3    = "mLGb/B4MTy7lebFCtSsPLyZet2g/7RhVs2VGYw5lTFw=";
      tiberiu1  = "021YHQrkW0jelFHbRaAYhMXr13XkC52MYFCTlMac3h8=";
      david1    = "N/+2L7/gr4cNXh5QWlHlU/HP3JELEPq3yRqJiHRdm2A=";
      david2    = "vvL7s3DRtfeQPWFNG6rdh0g9+aCb2EuAePA9ytfo6iE=";
      ramona1   = "4FNungU+bh000Xl1iK9M/IF6nyogsExGBxijnEQfIDc=";
      tibisor1  = "ACCujN9Qv0tt9TGW70faDP9lnMck7EFHa5dk/T5UMDU=";
      iza1      = "nBHQHSFHU/24IeKEJ0rFsV2xJTZCc4sRW/sI5/if+kc=";
      kerem1    = "zSoQM300aEExAnjUDwjHZi9r5tfrwsm4drEtrqVp90c=";
      hannah1   = "iRSXSbB/aiqXxRUyMLc2zfaJ+uARS9Jh5WOBwfQYkwU=";
    };
  };

  sshPubKey = "ssh-ed25519 AAAA… placeholder";  # human populates with their real key
  # Note: SSH password authentication remains enabled — intentional by human ruling.

  cloudflare = {
    tunnelId = "62ab1635-c6ea-44bc-a702-1bff07f392f7"; # real tunnel (created 2026-08-06 via dashboard token)
  };

  timeZone = "Europe/Berlin";
}
