# AdGuard Home — LAN DNS + DHCP (replaces Speedport router).
# OpenCode.md §3.2, §3.4. mutableSettings=false → fully declarative.
# Schema version 34 (pinned 26.05 AdGuardHome 0.107.78).
{ settings, ... }:
{
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    host = "127.0.0.1";
    port = 3000;
    settings = {
      users = [];
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        upstream_dns = [ "https://dns.quad9.net/dns-query" ];
        bootstrap_dns = [ "9.9.9.9" "149.112.112.112" ];
        fallback_dns = [ "1.1.1.1" ];
        enable_dnssec = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        rewrites = [
          { domain = "*.nanulab.de"; answer = settings.network.address; }
          { domain = "nanulab.de"; answer = settings.network.address; }
          { domain = settings.domains.mail; answer = settings.network.address; }
        ];
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
      ];
      dhcp = {
        enabled = true;
        interface_name = settings.network.interface;
        local_domain_name = "lan";
        dhcpv4 = {
          gateway_ip = settings.network.gateway;
          subnet_mask = "255.255.255.0";
          range_start = "10.0.0.100";
          range_end = "10.0.0.250";
          lease_duration = 86400;
          icmp_timeout_msec = 1000;
        };
      };
    };
  };
}
