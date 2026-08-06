# AdGuard Home — LAN DNS + DHCP (replaces Speedport router).
# OpenCode.md §3.2, §3.4. mutableSettings=false → fully declarative.
#
# v2 (2026-08-06): static leases + persistent clients keyed by user ([user]-[device]).
# Guest range 10.0.0.50-250, DHCP-only (no persistent client — labeled dynamically
# via runtime_sources.dhcp).
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
        ratelimit = 0;
        upstream_mode = "load_balance";
        upstream_dns = [
          "tls://one.one.one.one"
          "https://dns.cloudflare.com/dns-query"
          "https://dns.quad9.net/dns-query"
          "tls://dns.quad9.net"
        ];
        bootstrap_dns = [ "9.9.9.9" "149.112.112.112" ];
        fallback_dns = [ "1.1.1.1" ];
        enable_dnssec = true;
        cache_enabled = true;
        cache_size = 4194304;
        refuse_any = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        rewrites = [
          # Wildcard matches apex + all subdomains (*.nanulab.de → 10.0.0.2)
          { domain = "*.${settings.domains.internal}"; answer = settings.network.address; enabled = true; }
          { domain = settings.domains.mail; answer = settings.network.address; enabled = true; }
        ];
        safe_search.enabled = true;
        safe_search.bing = true;
        safe_search.duckduckgo = true;
        safe_search.ecosia = true;
        safe_search.google = true;
        safe_search.pixabay = true;
        safe_search.yandex = true;
        safe_search.youtube = true;
      };
      user_rules = [
        "@@||hotstream.app^$important"
        "@@||icanhazip.com^$important"
        "@@||hotplayer.app^$important"
        "@@||hdstreams.site^$important"
        "@@||resend.com^$important"
        "@@||ipify.org^$important"

      ];
      filters = [
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";  name = "AdGuard DNS filter"; id = 1; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_24.txt"; name = "1Hosts (Lite)"; id = 1785782586; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt";  name = "OISD Blocklist Small"; id = 1785782595; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt"; name = "HaGeZi's Normal Blocklist"; id = 1785782591; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";  name = "Peter Lowe's Blocklist"; id = 1785782599; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt"; name = "Steven Black's List"; id = 1785782601; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"; name = "Malicious URL Blocklist (URLHaus)"; id = 1785782596; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt"; name = "Phishing Army"; id = 1785782613; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt"; name = "Scam Blocklist by DurableNapkin"; id = 1785782611; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";  name = "NoCoin Filter List"; id = 1785782616; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt"; name = "Dandelion Sprout's Anti-Malware List"; id = 1785782629; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt"; name = "AdGuard DNS Popup Hosts filter"; id = 1785782589; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt"; name = "Dandelion Sprout's Anti Push Notifications"; id = 1785782602; }
      ];
      dhcp = {
        enabled = true;
        interface_name = settings.network.interface;
        local_domain_name = "lan";
        dhcpv4 = {
          gateway_ip = settings.network.gateway;
          subnet_mask = "255.255.255.0";
          range_start = "10.0.0.50";   # guests start at .50 (users occupy .8-.20)
          range_end = "10.0.0.250";
          lease_duration = 86400;
          icmp_timeout_msec = 1000;
        };
        # v2: static leases keyed by [user]-[device], .8–.20 for named users.
        # Iza/Kerem/Hannah have placeholder MACs (00:00:00:00:00:00) — human
        # fills real MACs post-plan. The lease reserves IP but no device matches.
        static_leases = [
          { mac = "d0:67:e5:40:49:4e"; ip = "10.0.0.2";   hostname = "homelab"; }
          # Dumitru (admin)
          { mac = "f6:5b:6b:f3:0e:87"; ip = "10.0.0.8";   hostname = "dumitru-phone"; }
          { mac = "2c:9c:58:60:c8:25"; ip = "10.0.0.9";   hostname = "dumitru-pc"; }
          # Adela
          { mac = "fe:02:26:df:0c:50"; ip = "10.0.0.10";  hostname = "adela-phone"; }
          { mac = "00:c3:f4:ea:fe:a6"; ip = "10.0.0.11";  hostname = "adela-tv"; }
          { mac = "68:79:c4:29:1d:44"; ip = "10.0.0.12";  hostname = "adela-air"; }
          # Tiberiu
          { mac = "da:08:7b:fe:cf:d7"; ip = "10.0.0.13";  hostname = "tiberiu-phone"; }
          # David
          { mac = "76:6f:b2:93:10:ce"; ip = "10.0.0.14";  hostname = "david-phone"; }
          { mac = "c4:9d:ed:c9:9a:13"; ip = "10.0.0.15";  hostname = "david-xbox"; }
          # Ramona
          { mac = "56:ea:b4:79:06:61"; ip = "10.0.0.16";  hostname = "ramona-phone"; }
          # Tibisor
          { mac = "26:05:a5:6c:e2:56"; ip = "10.0.0.17";  hostname = "tibisor-phone"; }
          # Iza / Kerem / Hannah — MACs missing, placeholder leases keep IPs reserved
          # TODO: human fills real MACs (see inputs/Homelab-v2-… ruling #11).
          # Lease with 00:00:00:00:00:00 is harmless (no device matches it)
          # but reserves the IP in the table.
          { mac = "00:00:00:00:00:00"; ip = "10.0.0.18";  hostname = "iza-phone"; }     # TODO MAC
          { mac = "00:00:00:00:00:00"; ip = "10.0.0.19";  hostname = "kerem-phone"; }   # TODO MAC
          { mac = "00:00:00:00:00:00"; ip = "10.0.0.20";  hostname = "hannah-phone"; }  # TODO MAC
        ];
      };
      # v2: persistent clients keyed by user (9 users, LAN+VPN IPs + hostname ids).
      # Tags: user_admin for dumitru, user_regular for all others.
      # Guests (10.0.0.50-250) have NO persistent client — labeled dynamically via
      # runtime_sources.dhcp (transient guests don't deserve per-client maintenance).
      clients = {
        persistent = [
          { name = "dumitru"; ids = [ "10.0.0.8" "10.0.0.9" "10.0.1.8" "10.0.1.9" "dumitru-phone" "dumitru-pc" ]; tags = [ "user_admin" ]; use_global_settings = true; }
          { name = "adela";   ids = [ "10.0.0.10" "10.0.0.11" "10.0.0.12" "10.0.1.10" "10.0.1.11" "10.0.1.12" "adela-phone" "adela-tv" "adela-air" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "tiberiu"; ids = [ "10.0.0.13" "10.0.1.13" "tiberiu-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "david";   ids = [ "10.0.0.14" "10.0.0.15" "10.0.1.14" "10.0.1.15" "david-phone" "david-xbox" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "ramona";  ids = [ "10.0.0.16" "10.0.1.16" "ramona-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "tibisor"; ids = [ "10.0.0.17" "10.0.1.17" "tibisor-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "iza";     ids = [ "10.0.0.18" "10.0.1.18" "iza-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "kerem";   ids = [ "10.0.0.19" "10.0.1.19" "kerem-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          { name = "hannah";  ids = [ "10.0.0.20" "10.0.1.20" "hannah-phone" ]; tags = [ "user_regular" ]; use_global_settings = true; }
          # Guests: NO persistent client — labeled dynamically via runtime_sources.dhcp.
          # The dhcp range (.50-.250) covers all transient guests without maintaining
          # per-guest entries.
        ];
      };
      # Runtime sources: DHCP + hosts + whois + rDNS. No ARP (stale clients).
      clients.runtime_sources = {
        whois = true;
        arp = false;
        rdns = true;
        dhcp = true;
        hosts = true;
      };
    };
  };
}
