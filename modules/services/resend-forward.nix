# modules/services/resend-forward.nix
# Resend inbound → personal email auto-forwarder.
# OpenCode.md §4 — Inbound MX points to Resend's AWS SES.
# This timer polls Resend every 3 minutes, fetches NEW received emails,
# and forwards them to the user's personal mailbox via Resend Send API.
# The user sees mail arrive as if it were delivered directly — no DDNS, no open ports.
{ config, pkgs, settings, ... }:
let
  forwardScript = pkgs.writeShellScriptBin "resend-forward-poll" ''
    set -euo pipefail
    RESEND_KEY="$(${pkgs.coreutils}/bin/cat /run/secrets/resend_api_key)"
    FORWARD_TO="d.nanu@mail.de"
    STATE_FILE="/var/lib/resend-forward/seen_ids"
    mkdir -p "$(dirname "$STATE_FILE")"
    touch "$STATE_FILE"

    # List received emails (JSON), 20 most recent
    EMAILS=$(${pkgs.curl}/bin/curl -s \
      -H "Authorization: Bearer $RESEND_KEY" \
      "https://api.resend.com/emails/receiving?limit=20" | \
      ${pkgs.jq}/bin/jq -c '.data[]? // empty')

    if [ -z "$EMAILS" ]; then
      exit 0
    fi

    echo "$EMAILS" | while IFS= read -r email; do
      ID=$(echo "$email" | ${pkgs.jq}/bin/jq -r '.id')
      FROM=$(echo "$email" | ${pkgs.jq}/bin/jq -r '.from')
      SUBJECT=$(echo "$email" | ${pkgs.jq}/bin/jq -r '.subject')
      TO=$(echo "$email" | ${pkgs.jq}/bin/jq -r '.to[0]')

      # Skip if already forwarded
      if grep -qxF "$ID" "$STATE_FILE" 2>/dev/null; then
        continue
      fi

      # Fetch email content
      CONTENT=$(${pkgs.curl}/bin/curl -s \
        -H "Authorization: Bearer $RESEND_KEY" \
        "https://api.resend.com/emails/receiving/$ID")
      TEXT=$(echo "$CONTENT" | ${pkgs.jq}/bin/jq -r '.text // ""')
      HTML=$(echo "$CONTENT" | ${pkgs.jq}/bin/jq -r '.html // ""')

      # Forward via Resend Send API (preserves original sender info in body)
      SEND_BODY=$(${pkgs.jq}/bin/jq -n \
        --arg from "hey@dnanu.de" \
        --argjson to "[\"$FORWARD_TO\"]" \
        --arg subject "Fwd($TO): $SUBJECT" \
        --arg text "From: $FROM\nTo: $TO\n\n$TEXT" \
        --arg html "<p><strong>From:</strong> $FROM<br><strong>To:</strong> $TO</p><hr>$HTML" \
        '{from: $from, to: $to, subject: $subject, text: $text, html: $html}')

      ${pkgs.curl}/bin/curl -s -X POST \
        -H "Authorization: Bearer $RESEND_KEY" \
        -H "Content-Type: application/json" \
        -d "$SEND_BODY" \
        "https://api.resend.com/emails" > /dev/null

      echo "$ID" >> "$STATE_FILE"
    done
  '';
in
{
  systemd.services.resend-forward-poll = {
    description = "Resend inbound email auto-forwarder";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${forwardScript}/bin/resend-forward-poll";
      StateDirectory = "resend-forward";
      User = "root";
      LoadCredential = "resend_api_key:${config.sops.secrets.resend_api_key.path}";
    };
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  systemd.timers.resend-forward-poll = {
    description = "Poll Resend inbox and forward new emails";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "60s";
      OnUnitActiveSec = "180s";
      Persistent = true;
    };
  };

  environment.systemPackages = [ pkgs.jq ];
}
