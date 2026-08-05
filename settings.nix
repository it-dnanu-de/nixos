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
  # Peers mirror the AdGuard DHCP static-lease layout on a 10.0.1.XXX base.
  # Public keys are not secret; private keys + PSKs live in sops (wireguard_peer_<name>_{private,psk}).
  network.wireguard = {
    port = 51820;
    subnet = "10.0.1.0/24";
    address = "10.0.1.1";
    endpoint = "vpn.dnanu.de";
    peers = [
      { name = "iPhone17Pro"; ip = "10.0.1.100"; publicKey = "hgUar95LcXopyebZfGRDbe0lZndqDfHDp/1CiSg1qlo="; } # admin (human)
      { name = "arch";        ip = "10.0.1.101"; publicKey = "iMocXpOjXHN0dEyOZqoPU0WHk99DZlEGs7vJePwfHgo="; } # admin (human)
      { name = "iphonexs";    ip = "10.0.1.102"; publicKey = "IKGIZcEp5jXPPhjD1y0yhH8NctiJOlCC0WEto6hNC2U="; }
      { name = "galaxys22u";  ip = "10.0.1.103"; publicKey = "021YHQrkW0jelFHbRaAYhMXr13XkC52MYFCTlMac3h8="; }
      { name = "samsungtv";   ip = "10.0.1.104"; publicKey = "WppvW2HLCQEl+7Q5CmSSKk9XOzAgf3wImZvGTGTGF1o="; }
      { name = "phillipsair"; ip = "10.0.1.105"; publicKey = "mLGb/B4MTy7lebFCtSsPLyZet2g/7RhVs2VGYw5lTFw="; }
      { name = "david";       ip = "10.0.1.106"; publicKey = "N/+2L7/gr4cNXh5QWlHlU/HP3JELEPq3yRqJiHRdm2A="; }
      { name = "ramona";      ip = "10.0.1.107"; publicKey = "4FNungU+bh000Xl1iK9M/IF6nyogsExGBxijnEQfIDc="; }
      { name = "tibisor";     ip = "10.0.1.108"; publicKey = "ACCujN9Qv0tt9TGW70faDP9lnMck7EFHa5dk/T5UMDU="; }
      { name = "xbox";        ip = "10.0.1.109"; publicKey = "vvL7s3DRtfeQPWFNG6rdh0g9+aCb2EuAePA9ytfo6iE="; }
      { name = "guest-1";     ip = "10.0.1.200"; publicKey = "qjHwXOzRAFWFlMoYAtk8wuFVgGgc1X4NUt2zo/foJBk="; }
      { name = "guest-2";     ip = "10.0.1.201"; publicKey = "Aia7/JBSA6UuKnKB+lqTSjo/lqetTlsMWL4BlFUOtgY="; }
    ];
  };

  sshPubKey = "ssh-ed25519 AAAA… placeholder";  # human populates with their real key
  # Note: SSH password authentication remains enabled — intentional by human ruling.

  cloudflare = {
    tunnelId = "00000000-0000-0000-0000-000000000000"; # placeholder — human sets real tunnel UUID (1% manual)
  };

  timeZone = "Europe/Berlin";
}
