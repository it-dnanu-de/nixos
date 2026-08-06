# users.nix — single source of truth for users, devices, and IP allocation.
# Consumed by: adguard.nix (DHCP leases + persistent clients), wireguard.nix
# (WG peers + QR renderer), nginx.nix (ACL allowlists), authelia.nix (user list).
#
# IP allocation (derived, not hardcoded):
#   admin   → LAN 10.0.0.1-8   · VPN 10.0.10.3-8 (admin0=10.0.0.0 net addr,
#             admin1=router 10.0.0.1, admin2=homelab 10.0.0.2 = WG server 10.0.10.2;
#             admin3-8 = VPN devices, name↔IP aligned)
#   dumitru → LAN 10.0.0.9-19  · VPN 10.0.10.9-19
#   adela   → LAN 10.0.0.20-29 · VPN 10.0.10.20-29
#   tiberiu → LAN 10.0.0.30-39 · VPN 10.0.10.30-39
#   david   → LAN 10.0.0.40-49 · VPN 10.0.10.40-49
#   ramona  → LAN 10.0.0.50-59 · VPN 10.0.10.50-59
#   tibisor → LAN 10.0.0.60-69 · VPN 10.0.10.60-69
#   iza     → LAN 10.0.0.70-79 · VPN 10.0.10.70-79
#   kerem   → LAN 10.0.0.80-89 · VPN 10.0.10.80-89
#   hannah  → LAN 10.0.0.90-99 · VPN 10.0.10.90-99
#   guests  → LAN 10.0.0.100-250 · no VPN
#
# The human only edits `hostname` + `mac` per device. IPs are DERIVED from
# the user's block offset + device index (1-based).

rec {
  # User block base offsets (LAN = base, VPN = base + 10.0.10.x mirroring)
  blocks = {
    admin   = { lan = 3;  vpn = 3;  };  # admin3-8 → .3-.8 (admin0/1/2 = net/router/homelab, no VPN)
    dumitru = { lan = 9;  vpn = 9;  };  # dumitru1-11 → .9-.19
    adela   = { lan = 20; vpn = 20; };
    tiberiu = { lan = 30; vpn = 30; };
    david   = { lan = 40; vpn = 40; };
    ramona  = { lan = 50; vpn = 50; };
    tibisor = { lan = 60; vpn = 60; };
    iza     = { lan = 70; vpn = 70; };
    kerem   = { lan = 80; vpn = 80; };
    hannah  = { lan = 90; vpn = 90; };
  };

  users = {
    admin = {
      tier = "admin";
      devices = [
        { hostname = "admin3"; mac = "2c:9c:58:60:c8:25"; }  # Arch PC
      ];
    };
    dumitru = {
      tier = "user";
      devices = [
        { hostname = "dumitru1"; mac = "f6:5b:6b:f3:0e:87"; }  # iPhone 17 Pro
      ];
    };
    adela = {
      tier = "user";
      devices = [
        { hostname = "adela1"; mac = "fe:02:26:df:0c:50"; }  # iPhone XS
        { hostname = "adela2"; mac = "00:c3:f4:ea:fe:a6"; }  # Samsung TV
        { hostname = "adela3"; mac = "68:79:c4:29:1d:44"; }  # Philips Air
      ];
    };
    tiberiu = {
      tier = "user";
      devices = [
        { hostname = "tiberiu1"; mac = "da:08:7b:fe:cf:d7"; }  # Galaxy S22U
      ];
    };
    david = {
      tier = "user";
      devices = [
        { hostname = "david1"; mac = "76:6f:b2:93:10:ce"; }  # iPhone 17 Pro Max
        { hostname = "david2"; mac = "c4:9d:ed:c9:9a:13"; }  # Xbox One
      ];
    };
    ramona = {
      tier = "user";
      devices = [
        { hostname = "ramona1"; mac = "56:ea:b4:79:06:61"; }  # iPhone 11
      ];
    };
    tibisor = {
      tier = "user";
      devices = [
        { hostname = "tibisor1"; mac = "26:05:a5:6c:e2:56"; }  # iPhone 14
      ];
    };
    iza = {
      tier = "user";
      devices = [
        { hostname = "iza1"; mac = "TODO"; }  # iPhone 15 — TODO MAC
      ];
    };
    kerem = {
      tier = "user";
      devices = [
        { hostname = "kerem1"; mac = "TODO"; }  # iPhone 16 Pro — TODO MAC
      ];
    };
    hannah = {
      tier = "user";
      devices = [
        { hostname = "hannah1"; mac = "TODO"; }  # iPhone 15 Pro — TODO MAC
      ];
    };
  };

  # Guest DHCP range (no VPN, no persistent client)
  guests = {
    lanStart = "10.0.0.100";
    lanEnd   = "10.0.0.250";
  };

  # Given a user name + device index (1-based), derive LAN and VPN IPs.
  # Example: userToIps "adela" 2 → { lan = "10.0.0.21"; vpn = "10.0.10.21"; }
  userToIps = userName: idx:
    let block = blocks.${userName};
    in {
      lan = "10.0.0.${toString (block.lan + idx - 1)}";
      vpn = "10.0.10.${toString (block.vpn + idx - 1)}";
    };
}
