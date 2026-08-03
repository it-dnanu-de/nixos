# ACME DNS-01 via Cloudflare (lego).
# OpenCode.md §8. Two wildcard certs, DNS-01 only, no HTTP-01.
# Uses quad9 resolver to bypass local AdGuard at boot (TXT-propagation race).
# One Cloudflare token for ddclient + ACME + cloudflared.
{ config, settings, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = settings.email.acme;
      dnsProvider = "cloudflare";
      dnsResolver = "9.9.9.9:53";
      credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_api_token.path;
    };
    certs."nanulab.de" = {
      domain = "nanulab.de";
      extraDomainNames = [ "*.nanulab.de" ];
      reloadServices = [ "nginx" ];
    };
    certs."mail.dnanu.de" = {
      domain = "mail.dnanu.de";
      extraDomainNames = [ "dnanu.de" "*.dnanu.de" ];
      reloadServices = [ "nginx" ]; # dovecot2 + postfix appended in build step 4
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
