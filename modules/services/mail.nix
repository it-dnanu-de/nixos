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
        "it@" "health@" "wealth@" "creative@" "academic@"
        "accounts@" "contact@" "partners@"
      ];
      sieveScript = ''
        require ["fileinto", "mailbox"];
        if address :is "to" "it@${settings.domains.public}"       { fileinto :create "IT";       stop; }
        if address :is "to" "health@${settings.domains.public}"   { fileinto :create "Health";   stop; }
        if address :is "to" "wealth@${settings.domains.public}"   { fileinto :create "Wealth";   stop; }
        if address :is "to" "creative@${settings.domains.public}" { fileinto :create "Creative"; stop; }
        if address :is "to" "academic@${settings.domains.public}" { fileinto :create "Academic"; stop; }
        if address :is "to" "accounts@${settings.domains.public}" { fileinto :create "Accounts"; stop; }
        if address :is "to" "contact@${settings.domains.public}"  { fileinto :create "Contact";  stop; }
        if address :is "to" "partners@${settings.domains.public}" { fileinto :create "Partners"; stop; }
      '';
    };

    accounts."admin@${settings.domains.public}" = {
      hashedPasswordFile = config.sops.secrets.mail_admin.path;
      aliases = [
        "postmaster@" "hostmaster@" "webmaster@"
        "abuse@" "security@"
      ];
    };
  };

  # ── Resend outbound relay (services.postfix directly) ──────
  # SASL credentials rendered to /run/secrets by sops (root:root 0400),
  # then postfix-setup.service reads it + runs postmap.
  sops.templates."postfix-sasl-passwd".content = ''
    [smtp.resend.com]:465 resend:${config.sops.placeholder.resend_api_key}
  '';

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
  sops.secrets.mail_hey.restartUnits = [ "dovecot2.service" ];
  sops.secrets.mail_admin.restartUnits = [ "dovecot2.service" ];

  # ── Thunderbird autoconfig ────────────────────────────────
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
}
