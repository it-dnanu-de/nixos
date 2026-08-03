# cloudflared — Cloudflare tunnel for public web surfaces.
# OpenCode.md §3.6. Tunnels dnanu.de, www, and autoconfig to local nginx.
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
      };
      default = "http_status:404";
    };
  };
}
