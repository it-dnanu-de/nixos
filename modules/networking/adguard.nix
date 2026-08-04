# AdGuard Home — LAN DNS + DHCP (replaces Speedport router).
# OpenCode.md §3.2, §3.4. mutableSettings=false → fully declarative.
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
          { domain = "nanulab.de";    answer = settings.network.address; enabled = true; }
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
        "@@||hdstreams.site^$important"
        "@@||resend.com^$important"
        "@@||ipify.org^$important"
        "@@||tailscale.com^$important"
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
          range_start = "10.0.0.100";
          range_end = "10.0.0.250";
          lease_duration = 86400;
          icmp_timeout_msec = 1000;
        };
        # Static DHCP leases — named devices with reservations
        static_leases = [
          { mac = "d0:67:e5:40:49:4e"; ip = "10.0.0.2";   hostname = "homelab"; }
          { mac = "f6:5b:6b:f3:0e:87"; ip = "10.0.0.100"; hostname = "iphone17pro"; }
          { mac = "2c:9c:58:60:c8:25"; ip = "10.0.0.101"; hostname = "arch"; }
          { mac = "fe:02:26:df:0c:50"; ip = "10.0.0.102"; hostname = "iphonexs"; }
          { mac = "da:08:7b:fe:cf:d7"; ip = "10.0.0.103"; hostname = "galaxys22u"; }
          { mac = "00:c3:f4:ea:fe:a6"; ip = "10.0.0.104"; hostname = "samsungtv"; }
          { mac = "68:79:c4:29:1d:44"; ip = "10.0.0.105"; hostname = "phillipsair"; }
          { mac = "76:6f:b2:93:10:ce"; ip = "10.0.0.106"; hostname = "david"; }
          { mac = "56:ea:b4:79:06:61"; ip = "10.0.0.107"; hostname = "ramona"; }
        ];
      };
      # Persistent clients — named, tagged, custom settings
      clients = {
        persistent = [
          {
            name = "Dumitru";
            ids = [ "10.0.0.100" "10.0.0.101" ];
            tags = [ "user_regular" ];
            use_global_settings = true;
          }
          {
            name = "T";
            ids = [ "10.0.0.103" ];
            tags = [ "user_regular" ];
            use_global_settings = true;
          }
          {
            name = "M";
            ids = [ "10.0.0.102" "10.0.0.104" "10.0.0.105" ];
            tags = [ "user_regular" ];
            use_global_settings = true;
          }
        ];
      };
      # Runtime sources: only DHCP + hosts (no ARP for stale/unknown clients)
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
