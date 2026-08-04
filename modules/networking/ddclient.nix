# ddclient — dynamic DNS for mail.dnanu.de A/AAAA records on Cloudflare.
# OpenCode.md §3.2, §4.4. Protocol cloudflare, token auth, interval 5min.
# Updates both IPv4 (via ipify-ipv4) and IPv6 (via ipify-ipv6).
{ config, settings, ... }:
{
  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    username = "token";
    passwordFile = config.sops.secrets.cloudflare_api_token.path;
    zone = settings.domains.public;
    domains = [ settings.domains.mail ];
    interval = "5min";
  };
}
