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

    extraApps = with pkgs.nextcloud33Packages.apps; {
      inherit mail calendar contacts;
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
}
