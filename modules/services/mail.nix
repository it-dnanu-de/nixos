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
    systemContact = "admin@${settings.domains.public}";  # required by tlsrpt (no SNM default)
    tlsrpt.enable = true;        # RFC 8460: send TLS reports to domains publishing _smtp._tls
    dmarcReporting.enable = true; # send daily DMARC aggregate reports (rspamd, timer included)

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

    # Static TLS policy for the Resend relay — must precede the tlspol socketmap.
    # Verified TLS with CA+hostname checking (upgrade from unverified encryption).
    mapFiles."tls_policy" = pkgs.writeText "tls_policy" ''
      [smtp.resend.com]:465 verify
      smtp.resend.com verify
    '';

    settings.main = {
      relayhost = [ "[smtp.resend.com]:465" ];
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
      smtp_sasl_security_options = "noanonymous";
      smtp_tls_wrappermode = "yes";
      # REMOVED: smtp_tls_security_level = lib.mkForce "encrypt";
      # tlspol + static tls_policy handle per-destination TLS now;
      # global level falls back to SNM/tlspol's "dane" (rarely used, harmless).
      smtp_tls_policy_maps = lib.mkBefore [ "hash:/var/lib/postfix/conf/tls_policy" ];

      # RFC-conformance restrictions — every legit MTA passes these.
      smtpd_helo_required = "yes";
      smtpd_helo_restrictions = [
        "permit_mynetworks"
        "reject_non_fqdn_helo_hostname"
        "reject_invalid_helo_hostname"
      ];
      smtpd_sender_restrictions = lib.mkAfter [
        "reject_non_fqdn_sender"
        "reject_unknown_sender_domain"
      ];
      smtpd_recipient_restrictions = lib.mkAfter [
        "reject_non_fqdn_recipient"
        "reject_unknown_recipient_domain"
        "reject_unauth_pipelining"
      ];
    };
  };

  # rspamd hardening (OpenCode.md §4.1, D2)
  services.rspamd.locals = {
    # Stock 4.0.1 defaults: reject=15/add_header=6/greylist=4.
    # Tighten reject 15→12; greylisting (4) and header-tagging (6) unchanged.
    "actions.conf".text = ''
      reject = 12;
      add_header = 6;
      greylist = 4;
    '';
    # Spamhaus is unreachable via public resolvers (AGH→quad9 returns
    # BLOCKED_OPENRESOLVER); disable that one list. Stock RBLs
    # (mailspike, dnswl, sem, blocklist.de, virusfree, SURBL/URIBL/DBL) stay on.
    "rbl.conf".text = ''
      rbls {
        spamhaus { enabled = false; }
      }
    '';
  };

  # Queue/service watchdog — alerts via Resend HTTPS API (independent of local
  # postfix, so it works even when the queue is the problem). $0: free tier,
  # existing sops key. Rate-limited: one alert per 6h.
  systemd.services.mail-queue-watch = {
    description = "Mail queue + service health watchdog";
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "mail-alert";
      LoadCredential = "resend_api_key:${config.sops.secrets.resend_api_key.path}";
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
    path = with pkgs; [ curl jq gawk postfix ];
    script = ''
      set -uo pipefail
      STATE="$STATE_DIRECTORY/last-sent"
      now=$(date +%s)
      last=$(cat "$STATE" 2>/dev/null || echo 0)
      problems=""

      for u in postfix dovecot2 rspamd; do
        systemctl is-active --quiet "$u" || problems="$problems $u-down"
      done

      # queue size + oldest age via postqueue JSON
      qjson=$(postqueue -j 2>/dev/null || true)
      qcount=$(echo "$qjson" | jq -s 'length')
      oldest=$(echo "$qjson" | jq -s 'map(.arrival_time // empty) | min // 0')
      [ "$qcount" -gt 2 ] && problems="$problems queue-size=$qcount"
      if [ "$oldest" != "0" ] && [ $((now - oldest)) -gt 1800 ]; then
        problems="$problems queue-oldest=$(( (now - oldest) / 60 ))min"
      fi

      if [ -n "$problems" ] && [ $((now - last)) -gt 21600 ]; then
        body="homelab mail watchdog:$problems"
        if curl -sS --fail -X POST "https://api.resend.com/emails" \
            -H "Authorization: Bearer $(cat "$CREDENTIALS_DIRECTORY/resend_api_key")" \
            -H "Content-Type: application/json" \
            -d "$(jq -nc --arg b "$body" '{from:"alert@dnanu.de",to:["hey@dnanu.de"],subject:"[homelab] mail watchdog",text:$b}')" > /dev/null; then
          echo "$now" > "$STATE"
          echo "alert sent:$problems"
        else
          echo "alert FAILED:$problems"; exit 1
        fi
      else
        echo "ok$problems"
      fi
    '';
  };

  systemd.timers.mail-queue-watch = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "*:0/15"; Persistent = true; };
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
