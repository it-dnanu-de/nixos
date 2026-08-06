# ACME DNS-01 via Cloudflare (lego).
# OpenCode.md §8. Two wildcard certs, DNS-01 only, no HTTP-01.
# Uses quad9 resolver to bypass local AdGuard at boot (TXT-propagation race).
# One Cloudflare token for ddclient + ACME + cloudflared.
{ config, pkgs, settings, ... }:
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
      domain = "dnanu.de";
      extraDomainNames = [ "*.dnanu.de" ];  # covers mail.dnanu.de, autoconfig, etc.
      reloadServices = [ "nginx" ]; # dovecot + postfix reloaded by SNM
      # Fires only on actual renewal, before postfix/dovecot reload (nixpkgs ExecStartPost order).
      # Synchronizes DANE TLSA record so receiving MTAs trust the new cert immediately.
      postRun = "${pkgs.systemd}/bin/systemctl start --no-block cloudflare-tlsa-sync.service || true";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
