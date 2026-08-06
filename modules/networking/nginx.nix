# nginx — reverse proxy + static site base.
# OpenCode.md §3.6, §9. Binds loopback-only on 8080 (cloudflared edge terminates TLS).
# TLS vhosts for services arrive in build steps 4–7; autoconfig added in step 4.
#
# v4 (2026-08-06): ACL allowlists derived from users.nix via isPeer filter.
# Admin vhosts: allow admin LAN (10.0.0.1-9, server is local) + admin VPN (10.0.10.3-9).
# User vhosts: allow user LAN (10.0.0.10-99) + all VPN (10.0.10.3-99), deny all.
# Guests (10.0.0.100-200) get nothing (no allow entry, denied by final deny all).
#
# Catch-all vhost: default_server on 0.0.0.0:443 + :80 with wildcard cert,
# returns 404. Fixes dead-name fall-through (e.g. profile.nanulab.de no longer
# leaks the AdGuard dashboard).
{ pkgs, settings, lib, users, ... }:
let
  # Filter users by tier
  adminUsers = lib.filterAttrs (n: u: u.tier == "admin") users.users;
  regularUsers = lib.filterAttrs (n: u: u.tier == "user") users.users;

  # Derive all admin DEVICE IPs (LAN + VPN) from users.nix — isPeer only
  # (excludes admin0/1/2 infra/server slots)
  adminPeerIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1);
      in if users.isPeer dev then [ ips.lan ips.vpn ] else [ ]
    ) userData.devices)
  ) adminUsers);

  # Derive all user DEVICE IPs (LAN + VPN) — isPeer only
  userPeerIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1);
      in if users.isPeer dev then [ ips.lan ips.vpn ] else [ ]
    ) userData.devices)
  ) regularUsers);

  # Admin allowlist: admin device IPs + explicit router (10.0.0.1) + server (10.0.0.2).
  # Server itself is local (127.0.0.1/nginx on the same host) but also has ACL entries.
  # Result: LAN .1-.9 + VPN 10.0.10.3-9
  adminAllowlist = ''
    allow 10.0.0.1/32;      # router (no VPN, but accessible from admin LAN)
    allow 10.0.0.2/32;      # homelab (server itself — localhost also works but belt-and-braces)
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") adminPeerIps)}
    deny all;
  '';

  # User allowlist: user device IPs + admin device IPs + router + server.
  # Guests (10.0.0.100-200) are NOT in any allow list → denied by final `deny all;`.
  # Result: LAN .1-.99 + VPN 10.0.10.3-99
  userAllowlist = ''
    allow 10.0.0.1/32;      # router
    allow 10.0.0.2/32;      # homelab
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") (userPeerIps ++ adminPeerIps))}
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

    # AdGuard UI — admin-VPN-only. LAN devices still use AdGuard as DNS on :53
    # but cannot reach the admin web UI.
    virtualHosts."adguard.${settings.domains.internal}" =
      mkAdminVhost "adguard.${settings.domains.internal}" "http://127.0.0.1:3000";

    # Catch-all — default_server on 0.0.0.0:443 + :80, wildcard cert, returns 404.
    # Fixes the dead-name fall-through bug: unmatched *.nanulab.de hosts (e.g.
    # profile.nanulab.de) used to fall through to the AdGuard dashboard on :443
    # and redirect to adguard on :80. Now they get a valid-cert 404.
    # The dnanu.de vhost has its own default on 127.0.0.1:8080 (different socket
    # → no conflict). nginx -t runs at build time as a safety gate.
    virtualHosts."catchall" = {
      serverName = "_";
      default = true;
      addSSL = true;
      useACMEHost = settings.domains.internal;   # *.nanulab.de wildcard cert
      locations."/".return = "404";
    };
  };
}
