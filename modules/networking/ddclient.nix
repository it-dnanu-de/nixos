# ddclient — dynamic DNS for mail.dnanu.de A record on Cloudflare.
# OpenCode.md §3.2, §4.4. Protocol cloudflare, token auth, interval 5min.
# Uses webv4 detection (ipify) by default — no explicit `use` needed.
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
    usev6 = "";
  };
}
