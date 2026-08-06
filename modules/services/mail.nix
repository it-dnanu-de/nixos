# Mail stack — simple-nixos-mailserver + Resend outbound relay + autoconfig.
# OpenCode.md §4. SNM pinned to nixos-26.05 branch (d357b9f).
{ config, lib, pkgs, settings, ... }:
{
  # ── SNM core ──────────────────────────────────────────────
  mailserver = {
    enable = true;
    fqdn = settings.domains.mail;
    domains = [ settings.domains.public ];
    stateVersion = 5;
    enableSubmission = true;
    enableSubmissionSsl = true;
    recipientDelimiter = "+";
    storage.path = "/fast/mail";
    x509.useACMEHost = settings.domains.mail;
    dkim.enable = true;
    localDnsResolver = false;  # AdGuard Home already owns port 53

    accounts."hey@${settings.domains.public}" = {
      hashedPasswordFile = config.sops.secrets.mail_hey.path;
      aliases = [
        "it@${settings.domains.public}" "health@${settings.domains.public}"
        "wealth@${settings.domains.public}" "creative@${settings.domains.public}"
        "academic@${settings.domains.public}" "accounts@${settings.domains.public}"
        "contact@${settings.domains.public}" "partners@${settings.domains.public}"
      ];
      sieveScript = ''
        require ["fileinto", "mailbox"];
        # :matches with * handles both bare alias and +subaddressing
        if address :matches "to" "it*@dnanu.de"       { fileinto :create "IT";       stop; }
        if address :matches "to" "health*@dnanu.de"   { fileinto :create "Health";   stop; }
        if address :matches "to" "wealth*@dnanu.de"   { fileinto :create "Wealth";   stop; }
        if address :matches "to" "creative*@dnanu.de" { fileinto :create "Creative"; stop; }
        if address :matches "to" "academic*@dnanu.de" { fileinto :create "Academic"; stop; }
        if address :matches "to" "accounts*@dnanu.de" { fileinto :create "Accounts"; stop; }
        if address :matches "to" "contact*@dnanu.de"  { fileinto :create "Contact";  stop; }
        if address :matches "to" "partners*@dnanu.de" { fileinto :create "Partners"; stop; }
      '';
    };

    accounts."admin@${settings.domains.public}" = {
      hashedPasswordFile = config.sops.secrets.mail_admin.path;
      aliases = [
        "postmaster@${settings.domains.public}" "hostmaster@${settings.domains.public}"
        "webmaster@${settings.domains.public}" "abuse@${settings.domains.public}"
        "security@${settings.domains.public}"
      ];
    };
  };

  # ── Resend outbound relay (services.postfix directly) ──────
  # SASL credentials rendered to /run/secrets by sops (root:root 0400),
  # then postfix-setup.service reads it + runs postmap.
  sops.templates."postfix-sasl-passwd" = {
    content = "[smtp.resend.com]:465 resend:${config.sops.placeholder.resend_api_key}";
    restartUnits = [ "postfix-setup.service" "postfix.service" ];
  };

  services.postfix = {
    mapFiles."sasl_passwd" = config.sops.templates."postfix-sasl-passwd".path;

    settings.main = {
      relayhost = [ "[smtp.resend.com]:465" ];
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
      smtp_sasl_security_options = "noanonymous";
      smtp_tls_wrappermode = "yes";
      smtp_tls_security_level = lib.mkForce "encrypt";
    };
  };

  # ── Secrets wiring ────────────────────────────────────────
  sops.secrets.mail_hey.restartUnits = [ "dovecot.service" ];
  sops.secrets.mail_admin.restartUnits = [ "dovecot.service" ];

  # Override SNM default: prevent auto-creating folders for +subaddressing
  # before sieve runs. Sieve's :create still works.
  services.dovecot2.settings.lmtp_save_to_detail_mailbox = lib.mkForce false;
  services.nginx.virtualHosts."autoconfig.${settings.domains.public}" = {
    listen = [ { addr = "127.0.0.1"; port = 8080; } ];
    locations."/mail/config-v1.1.xml" = {
      root = pkgs.runCommand "autoconfig-mail-root" { } ''
        mkdir -p "$out/mail"
        cat > "$out/mail/config-v1.1.xml" << 'XMLEOF'
        <?xml version="1.0" encoding="UTF-8"?>
        <clientConfig version="1.1">
          <emailProvider id="${settings.domains.public}">
            <domain>${settings.domains.public}</domain>
            <displayName>${settings.domains.public} Mail</displayName>
            <displayShortName>${settings.domains.public}</displayShortName>
            <incomingServer type="imap">
              <hostname>${settings.domains.mail}</hostname>
              <port>993</port>
              <socketType>SSL</socketType>
              <username>%EMAILADDRESS%</username>
              <authentication>password-cleartext</authentication>
            </incomingServer>
            <outgoingServer type="smtp">
              <hostname>${settings.domains.mail}</hostname>
              <port>465</port>
              <socketType>SSL</socketType>
              <username>%EMAILADDRESS%</username>
              <authentication>password-cleartext</authentication>
            </outgoingServer>
          </emailProvider>
        </clientConfig>
        XMLEOF
      '';
      extraConfig = "add_header Content-Type application/xml;";
    };
  };

  # MTA-STS policy host (§3.2, D3) — world-readable, served via cloudflared tunnel.
  # RFC 8461: senders fetch https://mta-sts.dnanu.de/.well-known/mta-sts.txt
  services.nginx.virtualHosts."mta-sts.${settings.domains.public}" = {
    listen = [ { addr = "127.0.0.1"; port = 8080; } ];
    locations."= /.well-known/mta-sts.txt" = {
      root = pkgs.writeTextDir ".well-known/mta-sts.txt" ''
        version: STSv1
        mode: enforce
        mx: ${settings.domains.mail}
        max_age: 86400
      '';
    };
    locations."/".return = "404";
  };
}
