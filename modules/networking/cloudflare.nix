# cloudflared — Cloudflare tunnel for public web surfaces.
# OpenCode.md §3.6. Tunnels dnanu.de, www, autoconfig, and profile.dnanu.de
# to local nginx. profile.dnanu.de uses https://127.0.0.1:443 (needs TLS + Authelia).
# Tunnel routes created once in CF dashboard per §12 (1% manual).
{ config, settings, ... }:
{
  services.cloudflared = {
    enable = true;
    tunnels.${settings.cloudflare.tunnelId} = {
      credentialsFile = config.sops.secrets.cloudflared_tunnel_cred.path;
      ingress = {
        "${settings.domains.public}" = "http://127.0.0.1:8080";
        "www.${settings.domains.public}" = "http://127.0.0.1:8080";
        "autoconfig.${settings.domains.public}" = "http://127.0.0.1:8080";
        "profile.${settings.domains.public}" = "https://127.0.0.1:443";
      };
      default = "http_status:404";
    };
  };
}
