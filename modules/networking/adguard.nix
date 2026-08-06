# AdGuard Home — LAN DNS + DHCP (replaces Speedport router).
# OpenCode.md §3.2, §3.4. mutableSettings=false → fully declarative.
#
# v3 (2026-08-06): static leases via leases.json (AGH 0.107.78 drops YAML static_leases
# silently — static leases live in the JSON DB at /var/lib/AdGuardHome/leases.json).
# Persistent clients and DHCP range generated from users.nix.
# Guest range 10.0.0.100-250, DHCP-only (no persistent client — labeled dynamically
# via runtime_sources.dhcp).
{ config, settings, users, lib, ... }:
let
  # Build the leases.json content from users.nix (static DHCP leases).
  # Only devices with real MACs (not "TODO") are included.
  staticLeases = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1); in
      lib.optional (dev.mac != "TODO") {
        expires = "";
        ip = ips.lan;
        hostname = dev.hostname;
        mac = dev.mac;
        static = true;
      }
    ) userData.devices
  ) users.users);

  leasesJson = builtins.toJSON {
    version = 1;
    leases = staticLeases;
  };

  # Persistent clients — all users get named persistent clients keyed by IP (LAN+VPN).
  persistentClients = lib.flatten (lib.mapAttrsToList (userName: userData:
    let
      ips = lib.flatten (lib.imap0 (idx: dev:
        let ip = users.userToIps userName (idx + 1); in [ ip.lan ip.vpn ]
      ) userData.devices);
      tag = if userData.tier == "admin" then "user_admin" else "user_regular";
    in [{
      name = userName;
      ids = ips;
      tags = [ tag ];
      use_global_settings = true;
    }]
  ) users.users);
in
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
          range_start = users.guests.lanStart;   # "10.0.0.100"
          range_end   = users.guests.lanEnd;     # "10.0.0.250"
          lease_duration = 86400;
          icmp_timeout_msec = 1000;
        };
        # NO static_leases — AGH 0.107.78 drops this YAML key silently.
        # Static leases live in leases.json (written by preStart below).
      };
      # v3: persistent clients keyed by user (10 users, LAN+VPN IPs — IP-only ids).
      # Tags: user_admin for admin, user_regular for all others.
      # Guests (10.0.0.100-250) have NO persistent client — labeled dynamically via
      # runtime_sources.dhcp.
      clients = {
        persistent = persistentClients;
        runtime_sources = {
          whois = true;
          arp = false;
          rdns = true;
          dhcp = true;
          hosts = true;
        };
      };
    };
  };

  # Write declarative static leases to leases.json BEFORE AGH starts.
  # AGH 0.107.78 does NOT read static_leases from YAML — they live in leases.json.
  # See internal/dhcpd/db.go: dbLoad() loads this file at DHCP server startup.
  # The NixOS module's preStart is typed as `lines` — our fragment appends cleanly
  # after the module's installFresh. Both run as the DynamicUser.
  systemd.services.adguardhome.preStart = ''
    # Write declarative static leases (AGH loads leases.json on start).
    # Derived from users.nix — only devices with real MACs (not "TODO") are included.
    echo '${leasesJson}' > "$STATE_DIRECTORY/leases.json"
    chmod 600 "$STATE_DIRECTORY/leases.json"
    echo "adguardhome preStart: wrote static leases to leases.json" >&2
  '';
}
