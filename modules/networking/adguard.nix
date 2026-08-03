# AdGuard Home — LAN DNS + DHCP (replaces Speedport router).
# OpenCode.md §3.2, §3.4. mutableSettings=false → fully declarative.
# Filter lists imported from running instance 2026-08-03.
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
          { domain = "*.nanulab.de";  answer = settings.network.address; enabled = true; }
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
        user_rules = [
          "@@||hotstream.app^$important"
          "@@||icanhazip.com^$important"
          "@@||hdstreams.site^$important"
          "@@||resend.com^$important"
          "@@||ipify.org^$important"
        ];
      };
      filters = [
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";  name = "AdGuard DNS filter"; id = 1; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_24.txt"; name = "1Hosts (Lite)"; id = 1785782586; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";  name = "Dan Pollock's List"; id = 1785782587; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt"; name = "AWAvenue Ads Rule"; id = 1785782588; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt"; name = "AdGuard DNS Popup Hosts filter"; id = 1785782589; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_70.txt"; name = "1Hosts (Xtra)"; id = 1785782590; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_34.txt"; name = "HaGeZi's Normal Blocklist"; id = 1785782591; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt"; name = "HaGeZi's Pro Blocklist"; id = 1785782592; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt"; name = "HaGeZi's Pro++ Blocklist"; id = 1785782593; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_49.txt"; name = "HaGeZi's Ultimate Blocklist"; id = 1785782594; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_5.txt";  name = "OISD Blocklist Small"; id = 1785782595; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"; name = "Malicious URL Blocklist (URLHaus)"; id = 1785782596; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt"; name = "OISD Blocklist Big"; id = 1785782597; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt"; name = "uBlock₀ filters – Badware risks"; id = 1785782598; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";  name = "Peter Lowe's Blocklist"; id = 1785782599; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_69.txt"; name = "ShadowWhisperer Tracking List"; id = 1785782600; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt"; name = "Steven Black's List"; id = 1785782601; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt"; name = "Dandelion Sprout's Anti Push Notifications"; id = 1785782602; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_6.txt";  name = "Dandelion Sprout's Game Console Adblock List"; id = 1785782603; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";  name = "The Big List of Hacked Malware Web Sites"; id = 1785782604; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_45.txt"; name = "HaGeZi's Allowlist Referral"; id = 1785782605; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_46.txt"; name = "HaGeZi's Anti-Piracy Blocklist"; id = 1785782606; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_67.txt"; name = "HaGeZi's Apple Tracker Blocklist"; id = 1785782607; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt"; name = "Stalkerware Indicators List"; id = 1785782608; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_42.txt"; name = "ShadowWhisperer's Malware List"; id = 1785782609; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_47.txt"; name = "HaGeZi's Gambling Blocklist"; id = 1785782610; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt"; name = "Scam Blocklist by DurableNapkin"; id = 1785782611; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_66.txt"; name = "HaGeZi's OPPO & Realme Tracker Blocklist"; id = 1785782612; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt"; name = "Phishing Army"; id = 1785782613; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_61.txt"; name = "HaGeZi's Samsung Tracker Blocklist"; id = 1785782614; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_65.txt"; name = "HaGeZi's Vivo Tracker Blocklist"; id = 1785782615; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";  name = "NoCoin Filter List"; id = 1785782616; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_68.txt"; name = "HaGeZi's URL Shortener Blocklist"; id = 1785782617; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_63.txt"; name = "HaGeZi's Windows/Office Tracker Blocklist"; id = 1785782618; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_60.txt"; name = "HaGeZi's Xiaomi Tracker Blocklist"; id = 1785782619; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt"; name = "HaGeZi's Threat Intelligence Feeds"; id = 1785782620; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";  name = "Perflyst and Dandelion Sprout's Smart-TV Blocklist"; id = 1785782621; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_56.txt"; name = "HaGeZi's The World's Most Abused TLDs"; id = 1785782622; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_52.txt"; name = "HaGeZi's Encrypted DNS/VPN/TOR/Proxy Bypass"; id = 1785782623; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_54.txt"; name = "HaGeZi's DynDNS Blocklist"; id = 1785782624; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_57.txt"; name = "ShadowWhisperer's Dating List"; id = 1785782625; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_71.txt"; name = "HaGeZi's DNS Rebind Protection"; id = 1785782626; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_62.txt"; name = "Ukrainian Security Filter"; id = 1785782627; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_55.txt"; name = "HaGeZi's Badware Hoster Blocklist"; id = 1785782628; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt"; name = "Dandelion Sprout's Anti-Malware List"; id = 1785782629; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_29.txt"; name = "CHN: AdRules DNS List"; id = 1785782630; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt"; name = "Phishing URL Blocklist (PhishTank and OpenPhish)"; id = 1785782631; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt"; name = "CHN: anti-AD"; id = 1785782632; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_16.txt"; name = "VNM: ABPVN List"; id = 1785782633; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_35.txt"; name = "HUN: Hufilter"; id = 1785782634; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_40.txt"; name = "TUR: Turkish Ad Hosts"; id = 1785782635; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_22.txt"; name = "IDN: ABPindo"; id = 1785782636; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_26.txt"; name = "TUR: turk-adlist"; id = 1785782637; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_17.txt"; name = "SWE: Frellwit's Swedish Hosts File"; id = 1785782638; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_19.txt"; name = "IRN: PersianBlocker list"; id = 1785782639; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_14.txt"; name = "POL: Polish filters for Pi-hole"; id = 1785782640; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_43.txt"; name = "ISR: EasyList Hebrew"; id = 1785782641; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_41.txt"; name = "POL: CERT Polska List of malicious domains"; id = 1785782642; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_25.txt"; name = "KOR: List-KR DNS"; id = 1785782643; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_13.txt"; name = "NOR: Dandelion Sprouts nordiske filtre"; id = 1785782644; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_15.txt"; name = "KOR: YousList"; id = 1785782645; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_20.txt"; name = "MKD: Macedonian Pi-hole Blocklist"; id = 1785782646; }
        { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_36.txt"; name = "LIT: EasyList Lithuania"; id = 1785782647; }
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
