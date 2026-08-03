# nginx — reverse proxy + static site base.
# OpenCode.md §3.6, §9. Binds loopback-only on 8080 (cloudflared edge terminates TLS).
# TLS vhosts for services arrive in build steps 4–7; autoconfig added in step 4.
{ pkgs, settings, ... }:
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
  };
}
