# Kea DHCP — LAN DHCPv4 + DHCPv6 (Decision B, 2026-08-06).
# AGH is now DNS-only. Replaces AGH's unreliable DHCP.
# Options verified against pinned nixos-26.05: services.kea.dhcp4 / services.kea.dhcp6
# (NOT dhcp4-server — that suffix is only in systemd unit names). Kea 3.0.3.
#
# v4: host reservations from users.nix dhcpReservations (10 real-MAC devices).
# v6: ULA fd10::/64, stateful pool fd10::100-fd10::200, DNS = fd10::2.
# GUA stays via Speedport SLAAC (accept_ra=1, no v6 forwarding).
# ctrl-agent and dhcp-ddns are disabled — no REST/DDNS surface.
{ settings, users, ... }:
{
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ settings.network.interface ];
      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };
      valid-lifetime = 86400;
      renew-timer = 43200;
      rebind-timer = 75600;
      option-data = [
        { name = "routers";             data = settings.network.gateway; }
        { name = "domain-name-servers"; data = settings.network.address; }
        { name = "domain-name";         data = "lan"; }
      ];
      subnet4 = [{
        id = 1;
        subnet = settings.network.subnet;
        pools = [{ pool = "${users.guests.lanStart} - ${users.guests.lanEnd}"; }];
        reservations = builtins.map (r: {
          hw-address = r.mac;
          ip-address = r.ip;
          hostname = r.hostname;
        }) users.dhcpReservations;
      }];
    };
  };

  services.kea.dhcp6 = {
    enable = true;
    settings = {
      interfaces-config.interfaces = [ settings.network.interface ];
      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp6.leases";
      };
      valid-lifetime = 86400;
      preferred-lifetime = 43200;
      subnet6 = [{
        id = 1;
        subnet = "fd10::/64";
        pools = [{ pool = "fd10::100 - fd10::200"; }];
        option-data = [
          { name = "dns-servers";  data = "fd10::2"; }
          { name = "domain-search"; data = "lan"; }
        ];
      }];
    };
  };
}
