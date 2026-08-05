# iOS profile vhost — serves WireGuard configs + (future) mail/CalDAV/CardDAV .mobileconfig.
# OpenCode.md §10 (amended 2026-08-05). DNS now rides inside WG peer configs; the old
# standalone dns.mobileconfig is retired.
#
# WireGuard peer configs and QR codes are rendered by the wireguard-profile-render
# oneshot (wireguard.nix) into /var/lib/mobileprofile/wg/ and served at /wg/.
{ config, ... }:
{
  services.nginx.virtualHosts."profile.nanulab.de" = {
    forceSSL = true;
    useACMEHost = "nanulab.de";
    basicAuthFile = config.sops.secrets.profile_basic_auth.path;
  };
}
