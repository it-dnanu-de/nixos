# profile.dnanu.de — per-user WireGuard configs + (future) mail/CalDAV/CardDAV .mobileconfig.
# OpenCode.md §10 (amended 2026-08-06). Public via cloudflared tunnel, guarded by Authelia
# (TOTP 2FA). Per-user pages at /<username>/ serve only that user's WG peers.
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
    locations."= /auth" = {
      extraConfig = ''
        internal;
        proxy_pass http://127.0.0.1:9091/api/verify;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URL $request_uri;
        proxy_set_header X-Original-Method $request_method;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    # /authelia/ — proxy to Authelia login UI.
    locations."/authelia/" = {
      proxyPass = "http://127.0.0.1:9091/";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
      '';
    };

    # per-user page: /<username>/ → /var/lib/mobileprofile/wg/<username>/
    # Only served if the Authelia-authenticated $auth_user matches the URL username.
    locations."~ ^/([a-z]+)/?\$" = {
      extraConfig = ''
        auth_request /auth;
        auth_request_set $auth_user $upstream_http_remote_user;
        # Only serve if the URL username matches the authenticated username.
        if ($auth_user != $1) { return 403; }
        alias /var/lib/mobileprofile/wg/$1/;
        try_files index.html =404;
        autoindex off;
        add_header Cache-Control "no-store";
      '';
    };

    # Root → redirect to /<auth_user>/
    locations."= /" = {
      extraConfig = ''
        auth_request /auth;
        auth_request_set $auth_user $upstream_http_remote_user;
        return 302 /$auth_user/;
      '';
    };
  };
}
