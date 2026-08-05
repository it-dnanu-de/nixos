{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      cloudflare_api_token = {};

      cloudflared_tunnel_cred = {};



      resend_api_key = {};
      mail_hey = {};
      mail_admin = {};
      airvpn_wg_conf = {};
      b2_account_id = {};
      b2_account_key = {};
      restic_password = {};
      nextcloud_admin_pass = {};
      vaultwarden_admin_token = {};
      slskd_env = {};
      profile_basic_auth = {
        # nginx (user nginx) reads this for basic auth on profile.nanulab.de — must be group-readable
        owner = "root";
        group = "nginx";
        mode = "0440";
      };
      mobileca_key = {};
      mobileca_cert = {};
      booklore_db_password = {};
    };
  };
}
