# nginx — reverse proxy + static site base.
# OpenCode.md §3.6, §9. Binds loopback-only on 8080 (cloudflared edge terminates TLS).
# TLS vhosts for services arrive in build steps 4–7; autoconfig added in step 4.
#
# v2 (2026-08-06): mkAdminVhost / mkUserVhost helpers for two-tier VPN access control.
# Admin vhosts: allow only admin VPN peers (10.0.1.8, 10.0.1.9), deny all.
# User vhosts: allow LAN + all VPN (user + admin), deny internet.
# IP-based ACL is stateless, zero-daemon, survives Authelia outages (§3.3 amended).
{ pkgs, settings, ... }:
let
  peers = settings.network.wireguard.peers;

  # Derive admin and user VPN IP lists from settings.nix peer registry.
  adminVpnIps = builtins.filter (p: p.admin) peers;
  userVpnIps = builtins.filter (p: !p.admin) peers;

  # Build nginx allow/deny directives from an IP list.
  mkAllowString = ips: builtins.concatStringsSep "\n    " (map (p: "allow ${p.ip}/32;") ips) + "\n    deny all;";

  # Admin vhost ACL: admin VPN peers + admin's LAN IPs (iOS routes local-subnet
  # traffic directly over LAN, bypassing the tunnel). Deny everything else.
  adminAllowlist = ''
    ${mkAllowString adminVpnIps}
    ${builtins.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") settings.network.adminLan)}
    deny all;
  '';

  # User vhost ACL: LAN + all VPN peers (user + admin).
  userAllowlist = ''
    allow ${settings.network.subnet};
    ${mkAllowString (adminVpnIps ++ userVpnIps)}
  '';

  # mkAdminVhost: forceSSL + admin-VPN-only allowlist + proxy to backend.
  mkAdminVhost = fqdn: backend: {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    locations."/" = {
      proxyPass = backend;
      proxyWebsockets = true;
      extraConfig = adminAllowlist;
    };
  };

  # mkUserVhost: forceSSL + LAN+VPN allowlist + proxy to backend.
  mkUserVhost = fqdn: backend: {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    locations."/" = {
      proxyPass = backend;
      proxyWebsockets = true;
      extraConfig = userAllowlist;
    };
  };
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."${settings.domains.public}" = {
      default = true;
      serverAliases = [ "www.${settings.domains.public}" ];
      listen = [
        {
          addr = "127.0.0.1";
          port = 8080;
        }
      ];
      root = pkgs.writeTextDir "index.html" "<h1>dnanu.de — place-holder (Hugo lands in build step 7)</h1>";
    };

    # AdGuard UI — admin-VPN-only (human ruling #7). LAN devices still use
    # AdGuard as DNS on :53 but cannot reach the admin web UI.
    virtualHosts."adguard.${settings.domains.internal}" =
      mkAdminVhost "adguard.${settings.domains.internal}" "http://127.0.0.1:3000";
  };
}
