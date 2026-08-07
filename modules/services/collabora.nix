# Collabora Online — LibreOffice-based office suite for Nextcloud (OpenCode.md §9, build step 5).
# Binds localhost:9980. WOPI allowlist scoped to cloud.nanulab.de.
# Nginx proxies with WebSocket support (mkUserVhost already does this).
{ config, lib, pkgs, settings, users, ... }:
let
  helpers = import ../networking/nginx-helpers.nix { inherit lib settings users; };
in
{
  services.collabora-online = {
    enable = true;
    port = 9980;

    settings = {
      storage.wopi."@allow" = true;
      storage.wopi.host = [ "cloud\\.${settings.domains.internal}" ];
    };

    aliasGroups = [{
      host = "https://cloud.${settings.domains.internal}";
      aliases = [];
    }];
  };

  services.nginx.virtualHosts."office.${settings.domains.internal}" =
    helpers.mkUserVhost "office.${settings.domains.internal}" "http://127.0.0.1:9980";
}
