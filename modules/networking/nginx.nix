# nginx — reverse proxy + static site base.
# OpenCode.md §3.6, §9. Binds loopback-only on 8080 (cloudflared edge terminates TLS).
# TLS vhosts for services arrive in build steps 4–7; autoconfig added in step 4.
#
# v3 (2026-08-06): ACL helpers derive IP allowlists from users.nix.
# Admin vhosts: allow admin LAN (10.0.0.3-8) + admin VPN (10.0.10.3-8), deny all.
# User vhosts: allow user LAN (10.0.0.9-99) + all VPN (10.0.10.3-99), deny all.
# Guests (10.0.0.100-250) get NOTHING (no allow entry, denied by the final deny all).
{ pkgs, settings, lib, users, ... }:
let
  # Filter users by tier
  adminUsers = lib.filterAttrs (n: u: u.tier == "admin") users.users;
  regularUsers = lib.filterAttrs (n: u: u.tier == "user") users.users;

  # Derive all admin device IPs (LAN + VPN) from users.nix
  adminIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1); in [ ips.lan ips.vpn ]
    ) userData.devices)
  ) adminUsers);

  # Derive all user device IPs (LAN + VPN) from users.nix
  userIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1); in [ ips.lan ips.vpn ]
    ) userData.devices)
  ) regularUsers);

  # Admin allowlist: admin IPs only
  adminAllowlist = ''
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") adminIps)}
    allow 10.0.0.1/32;      # router (no VPN, but accessible from admin LAN)
    allow 10.0.0.2/32;      # homelab (server itself)
    deny all;
  '';

  # User allowlist: user IPs + admin IPs (admins see everything).
  # Guests (10.0.0.100-250) are NOT in any allow list → denied by final `deny all;`.
  userAllowlist = ''
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") (userIps ++ adminIps))}
    allow 10.0.0.1/32;      # router
    allow 10.0.0.2/32;      # homelab
    deny all;
  '';

  # mkAdminVhost: forceSSL + admin-IP-only allowlist + proxy to backend.
  mkAdminVhost = fqdn: backend: {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    locations."/" = {
      proxyPass = backend;
      proxyWebsockets = true;
      extraConfig = adminAllowlist;
    };
  };

  # mkUserVhost: forceSSL + user+admin IP allowlist + proxy to backend.
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
