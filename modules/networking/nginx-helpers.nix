# nginx-helpers — shared ACL derivation + vhost helpers.
# Extracted from nginx.nix so service modules can import them without re-deriving.
# Consumed by: nginx.nix, nextcloud.nix, vaultwarden.nix, immich.nix, collabora.nix.
{ lib, settings, users }:
let
  adminUsers = lib.filterAttrs (n: u: u.tier == "admin") users.users;
  regularUsers = lib.filterAttrs (n: u: u.tier == "user") users.users;

  adminPeerIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1);
      in if users.isPeer dev then [ ips.lan ips.vpn ] else [ ]
    ) userData.devices)
  ) adminUsers);

  userPeerIps = lib.flatten (lib.mapAttrsToList (userName: userData:
    lib.flatten (lib.imap0 (idx: dev:
      let ips = users.userToIps userName (idx + 1);
      in if users.isPeer dev then [ ips.lan ips.vpn ] else [ ]
    ) userData.devices)
  ) regularUsers);

  adminAllowlist = ''
    allow 10.0.0.1/32;      # router (no VPN, but accessible from admin LAN)
    allow 10.0.0.2/32;      # homelab (server itself — localhost also works but belt-and-braces)
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") adminPeerIps)}
    deny all;
  '';

  userAllowlist = ''
    allow 10.0.0.1/32;      # router
    allow 10.0.0.2/32;      # homelab
    ${lib.concatStringsSep "\n    " (map (ip: "allow ${ip}/32;") (userPeerIps ++ adminPeerIps))}
    deny all;
  '';

  mkAdminVhost = fqdn: backend: {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    locations."/" = {
      proxyPass = backend;
      proxyWebsockets = true;
      extraConfig = adminAllowlist;
    };
  };

  mkUserVhost = fqdn: backend: {
    forceSSL = true;
    useACMEHost = settings.domains.internal;
    locations."/" = {
      proxyPass = backend;
      proxyWebsockets = true;
      extraConfig = userAllowlist;
    };
  };
in {
  inherit adminAllowlist userAllowlist mkAdminVhost mkUserVhost;
}
