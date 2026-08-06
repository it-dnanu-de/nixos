# Authelia — authentication and authorization server (OpenCode.md §10, plan §3).
# Native module, nixos-26.05. Single instance "main" on tcp://127.0.0.1:9091/.
# File-based user DB (users.yaml from sops). TOTP 2FA. Guards profile.dnanu.de
# via nginx auth_request.
{ config, settings, ... }:
{
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets.authelia_jwt.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia_storage_key.path;
    };
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      server.address = "tcp://127.0.0.1:9091/";
      log = {
        level = "info";
        format = "text";
      };
      authentication_backend = {
        file = {
          # Point directly at the sops-rendered users.yaml (0400 authelia-main).
          # NOT /var/lib/authelia-main/users.yaml — that path holds Authelia's
          # default template and would ignore our 9 users.
          path = config.sops.secrets.authelia_users_yaml.path;
          watch = false;
          # Passwords + TOTP seeds live in sops (authelia_users_yaml, 0400 authelia-main).
          # File is rendered at activation; use restartTriggers to pick up changes.
        };
      };
      session = {
        domain = settings.domains.public;  # dnanu.de — cookie scoped for cloudflared tunnel
        name = "authelia_session";
        same_site = "lax";
        expiration = "1h";
        inactivity = "5m";
        remember_me = "1M";
      };
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";
      access_control = {
        default_policy = "deny";
        rules = [
          { domain = "profile.${settings.domains.public}"; policy = "two_factor"; }
        ];
      };
      totp = {
        issuer = "nanulab";
      };
      # No SMTP relay configured for Authelia (mail is a separate system).
      # Filesystem notifier writes notification emails (TOTP enrollment links,
      # password reset) to a local dir instead of sending them. Admin can read
      # them if ever needed; users self-enroll TOTP interactively, so this is
      # mostly a formality to satisfy Authelia's notifier requirement.
      notifier = {
        filesystem = {
          filename = "/var/lib/authelia-main/notifications.txt";
        };
      };
    };
  };
}
