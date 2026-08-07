# Nextcloud — collaborative cloud platform (OpenCode.md §9, build step 5).
# Native NixOS module. PostgreSQL + Redis auto-provisioned. RAM-tuned PHP-FPM
# pool for the 6GB Dell (pm=ondemand, max_children=8).
{ config, lib, pkgs, settings, users, ... }:
let
  helpers = import ../networking/nginx-helpers.nix { inherit lib settings users; };
in
{
  services.nextcloud = {
    enable = true;
    hostName = "cloud.${settings.domains.internal}";
    https = true;
    maxUploadSize = "16G";
    package = pkgs.nextcloud33;
    config.dbtype = "pgsql";
    database.createLocally = true;
    config.adminpassFile = config.sops.secrets.nextcloud_admin_pass.path;
    configureRedis = true;

    # Fixes reported setup warnings (declarative, no web-UI poking):
    # - maintenance window: run background jobs at 02:30
    # - default phone region: DE
    # - server ID: single PHP server identifier
    # - integrity checker stays disabled (nix store path changes each rebuild — standard on NixOS)
    # - log_type=file so the Logreader app works (module default is systemd → Logreader error)
    settings = {
      maintenance_window_start = 2;
      default_phone_region = "DE";
      serverId = "homelab-dell";
      log_type = "file";
    };

    # opcache.interned_strings_buffer default is 8 → warning "nearly full".
    # Bump to 32 (recommended >8). Additive; other phpOptions untouched.
    phpOptions."opcache.interned_strings_buffer" = "32";

    extraApps = with pkgs.nextcloud33Packages.apps; {
      inherit mail calendar contacts richdocuments; # richdocuments = Nextcloud Office → coolwsd (office.nanulab.de)
    };

    poolSettings = {
      "pm" = "ondemand";
      "pm.max_children" = "8";
      "pm.start_servers" = "2";
      "pm.min_spare_servers" = "1";
      "pm.max_spare_servers" = "3";
      "pm.max_requests" = "500";
    };
  };

  services.nginx.virtualHosts."cloud.${settings.domains.internal}" = {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    extraConfig = helpers.userAllowlist;
  };

  # Declarative WOPI config: point richdocuments at the local Collabora server.
  # Idempotent oneshot — no-op when wopi_url already set.
  systemd.services.nextcloud-richdocuments-wopi = {
    description = "Point Nextcloud richdocuments at local Collabora server";
    after = [ "nextcloud-setup.service" ];
    requires = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      OCC=${config.services.nextcloud.occ}/bin/nextcloud-occ
      CURRENT=$($OCC config:app:get richdocuments wopi_url 2>/dev/null || true)
      if [ "$CURRENT" != "https://office.${settings.domains.internal}" ]; then
        $OCC config:app:set richdocuments wopi_url --value "https://office.${settings.domains.internal}"
      fi
    '';
  };
}
