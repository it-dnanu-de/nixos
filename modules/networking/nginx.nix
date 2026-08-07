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
#
# 2026-08-07: ACL derivation + mkVhost helpers extracted to nginx-helpers.nix
# so service modules can reuse them without re-deriving.
{ pkgs, settings, lib, users, ... }:
let
  helpers = import ./nginx-helpers.nix { inherit lib settings users; };
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

    virtualHosts."adguard.${settings.domains.internal}" =
      helpers.mkAdminVhost "adguard.${settings.domains.internal}" "http://127.0.0.1:3000";

    virtualHosts."catchall" = {
      serverName = "_";
      default = true;
      addSSL = true;
      useACMEHost = settings.domains.internal;
      locations."/".return = "404";
    };
  };
}
