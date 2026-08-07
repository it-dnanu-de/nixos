# Immich — self-hosted photo and video management (OpenCode.md §9, build step 5).
# PostgreSQL + Redis auto-provisioned. ML disabled on Dell (CPU too weak).
# Media stored on /fast/immich; nginx body size raised to 500M for uploads.
{ config, lib, pkgs, settings, users, ... }:
let
  helpers = import ../networking/nginx-helpers.nix { inherit lib settings users; };
in
{
  services.immich = {
    enable = true;
    mediaLocation = "/fast/immich";
    machine-learning.enable = false; # Dell CPU too weak
    host = "127.0.0.1";
    port = 2283;
  };

  # media group (§5): immich reads/writes /fast/user/hey + /slow/shared-media
  systemd.services.immich-server.serviceConfig.SupplementaryGroups = [ "media" ];

  services.nginx.virtualHosts."photos.${settings.domains.internal}" = lib.recursiveUpdate
    (helpers.mkUserVhost "photos.${settings.domains.internal}" "http://127.0.0.1:2283")
    {
      extraConfig = ''
        client_max_body_size 500M;
      '';
    };
}
