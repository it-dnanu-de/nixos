# profile.dnanu.de — per-user WireGuard configs + (future) mail/CalDAV/CardDAV .mobileconfig.
# OpenCode.md §10 (amended 2026-08-06). Public via cloudflared tunnel, guarded by Authelia
# (TOTP 2FA). Each authenticated user is served ONLY their own peers' dir.
#
# DNS now rides inside WG peer configs; the old standalone dns.mobileconfig is retired.
# WireGuard peer configs and QR codes are rendered by wireguard-profile-render oneshot
# (wireguard.nix) into /var/lib/mobileprofile/wg/<user>/.
{ config, settings, ... }:
{
  services.nginx.virtualHosts."profile.${settings.domains.public}" = {
    forceSSL = true;
    useACMEHost = settings.domains.public;   # *.dnanu.de wildcard cert
    # NO basicAuthFile — Authelia auth_request replaces shared basic auth (§10).

    # /auth — internal endpoint for nginx auth_request to Authelia's verify endpoint.
    # Authelia is mounted at /authelia (server.address path), so verify lives at
    # /authelia/api/verify.
    locations."= /auth" = {
      extraConfig = ''
        internal;
        proxy_pass http://127.0.0.1:9091/authelia/api/verify;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URL $request_uri;
        proxy_set_header X-Original-Method $request_method;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    # /authelia/ — proxy to Authelia login UI (mounted at /authelia on 9091).
    locations."/authelia/" = {
      proxyPass = "http://127.0.0.1:9091";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
      '';
    };

    # Named location: unauth'd requests land here → Authelia login with rd= return-to.
    locations."@authelia_login" = {
      extraConfig = ''
        return 302 /authelia/?rd=$scheme://$host$request_uri;
      '';
    };

    # Everything else under the vhost: gate via Authelia and serve the AUTHENTICATED
    # user's own directory. root is derived from $auth_user (set by auth_request), so
    # no URL can reach another user's files — there is nothing to guess.
    # (The earlier `if ($auth_user != $1)` pattern is broken in nginx: `if` runs in the
    # rewrite phase before auth_request sets $auth_user, so it always returned 403.)
    locations."/" = {
      extraConfig = ''
        auth_request /auth;
        auth_request_set $auth_user $upstream_http_remote_user;
        error_page 401 = @authelia_login;
        root /var/lib/mobileprofile/wg/$auth_user;
        index index.html;
        autoindex off;
        add_header Cache-Control "no-store";
      '';
    };
  };
}
