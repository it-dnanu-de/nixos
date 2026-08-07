# Vaultwarden — self-hosted Bitwarden server (OpenCode.md §9, build step 5).
# SQLite backend (no PostgreSQL needed). ADMIN_TOKEN via sops template env file.
# Built-in nginx disabled; we supply our own vhost with WebSocket endpoints + ACLs.
{ config, lib, pkgs, settings, users, ... }:
let
  helpers = import ../networking/nginx-helpers.nix { inherit lib settings users; };
in
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    configureNginx = false;

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_ALLOWED = false;
      ENABLE_WEBSOCKET = true;
      DOMAIN = "https://vault.${settings.domains.internal}";
      # Declared admin-page settings (no web-UI poking):
      ENABLE_PUSH_NOTIFICATION = false;      # no mobile push relay — VPN-only access
      SMTP_HOST = "127.0.0.1";               # local postfix (mynetworks includes loopback → relays to Resend)
      SMTP_PORT = 25;                        # loopback relay, no auth needed
      SMTP_SECURITY = "none";
      SMTP_FROM = "vaultwarden@${settings.domains.public}";
      SMTP_FROM_NAME = "Vaultwarden";
    };

    environmentFile = [ config.sops.templates."vaultwarden-env".path ];
  };

  sops.templates."vaultwarden-env" = {
    content = "ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}";
    mode = "0400";
    owner = "vaultwarden";
  };

  sops.secrets.vaultwarden_admin_token.restartUnits = [ "vaultwarden.service" ];

  services.nginx.virtualHosts."vault.${settings.domains.internal}" = lib.recursiveUpdate
    (helpers.mkUserVhost "vault.${settings.domains.internal}" "http://127.0.0.1:8222")
    {
      locations = {
        "/notifications/hub" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
          extraConfig = helpers.userAllowlist;
        };
        "/notifications/anonymous-hub" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
          extraConfig = helpers.userAllowlist;
        };
      };
    };
}
